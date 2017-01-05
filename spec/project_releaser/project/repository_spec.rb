require 'spec_helper'

describe ProjectReleaser::Project::Repository do
  let(:dir) { '/path/to/repository' }
  let(:subject) { ProjectReleaser::Project::Repository.new dir }
  let(:git) { double 'git lib' }

  it 'raises exception if directory has no git repository' do
    allow(Git).to receive(:open).with(dir).and_raise(ArgumentError)
    expect { subject }.to raise_error ProjectReleaser::Project::Repository::RepositoryNotFound
  end

  context 'when dir has repository' do
    before :each do
      allow(Git).to receive(:open).with(dir).and_return(git)
    end

    describe '#current_version' do
      it 'takes version from last tag' do
        tag_1 = double 'tag', name: 'v1.2.3'
        tag_2 = double 'tag', name: 'v1.2.4'
        allow(git).to receive(:tags).and_return([tag_1, tag_2])
        expect(subject.current_version).to eq major: 1, minor: 2, patch: 4
      end

      it 'supports version without v prefix' do
        tag = double 'tag', name: '1.2.8'
        allow(git).to receive(:tags).and_return([tag])
        expect(subject.current_version).to eq major: 1, minor: 2, patch: 8
      end

      it 'recognizes partial versions' do
        tag = double 'tag', name: 'v1.2'
        allow(git).to receive(:tags).and_return([tag])
        expect(subject.current_version).to eq major: 1, minor: 2, patch: 0
      end

      it 'sorts tags by patch version' do
        tag_1 = double 'tag', name: 'v1.2.10'
        tag_2 = double 'tag', name: 'v1.2.2'
        allow(git).to receive(:tags).and_return([tag_1, tag_2])
        expect(subject.current_version).to eq major: 1, minor: 2, patch: 10
      end

      it 'sorts tags by minor version' do
        tag_1 = double 'tag', name: 'v1.10.2'
        tag_2 = double 'tag', name: 'v1.2.2'
        allow(git).to receive(:tags).and_return([tag_1, tag_2])
        expect(subject.current_version).to eq major: 1, minor: 10, patch: 2
      end

      it 'sorts tags by patch version' do
        tag_1 = double 'tag', name: 'v0.2.2'
        tag_2 = double 'tag', name: 'v1.2.2'
        allow(git).to receive(:tags).and_return([tag_1, tag_2])
        expect(subject.current_version).to eq major: 1, minor: 2, patch: 2
      end

      it 'returns default version when there are none' do
        allow(git).to receive(:tags).and_return([])
        expect(subject.current_version).to eq major: 1, minor: 0, patch: 0
      end

      it 'returns default version when there are no valid tags' do
        tag = double 'tag', name: 'random tag'
        allow(git).to receive(:tags).and_return([tag])
        expect(subject.current_version).to eq major: 1, minor: 0, patch: 0
      end

      it 'ignores tags that do not match semantic versioning and returns default one' do
        tag_1 = double 'tag', name: 'g1.2.3'
        tag_2 = double 'tag', name: 'random string'
        allow(git).to receive(:tags).and_return([tag_1, tag_2])
        expect(subject.current_version).to eq major: 1, minor: 0, patch: 0
      end
    end

    describe '#pull' do
      it 'updates provided branches from remote urls' do
        remote_1 = double 'remote url', name: 'remote_1'
        remote_2 = double 'remote url', name: 'remote_2'

        allow(git).to receive(:remotes).and_return([remote_1, remote_2])

        expect(git).to receive(:checkout).with(:branch_1).ordered
        expect(git).to receive(:fetch).with('remote_1').ordered
        expect(git).to receive(:pull).with('remote_1', :branch_1).ordered
        expect(git).to receive(:fetch).with('remote_2').ordered
        expect(git).to receive(:pull).with('remote_2', :branch_1).ordered

        expect(git).to receive(:checkout).with(:branch_2).ordered
        expect(git).to receive(:fetch).with('remote_1').ordered
        expect(git).to receive(:pull).with('remote_1', :branch_2).ordered
        expect(git).to receive(:fetch).with('remote_2').ordered
        expect(git).to receive(:pull).with('remote_2', :branch_2).ordered

        subject.pull([:branch_1, :branch_2])
      end
    end

    describe '#merge' do
      it 'merges two branches' do
        expect(git).to receive(:checkout).with(:branch_1).ordered
        expect(git).to receive(:merge).with(:branch_2).ordered

        subject.merge :branch_1, :branch_2
      end

      it 'uses mergetool to solve conflicts' do
        allow(git).to receive(:checkout).with(:branch_1)
        allow(git).to receive(:merge).with(:branch_2).and_throw Git::GitExecuteError.new
        expect(Kernel).to receive(:system).with('git mergetool').ordered
        expect(git).to receive(:commit).with('resolved merge conflict')

        subject.merge :branch_1, :branch_2
      end
    end

    describe '#push' do
      it 'tags with provided version and pushes to all remotes urls' do
        remote = double 'remote url', name: 'some_origin'
        allow(git).to receive(:remotes).and_return([remote])

        expect(git).to receive(:checkout).with(:branch).ordered
        expect(git).to receive(:add_tag).with('v1.0.0')
        expect(git).to receive(:push).with('some_origin', :branch).ordered
        expect(git).to receive(:push).with('some_origin', 'v1.0.0').ordered

        subject.push :branch, 'v1.0.0'
      end
    end

    describe '#remotes' do
      it 'returns hash with remote names and urls' do
        remote_1 = double 'remote url', name: 'remote_1', url: 'url_1'
        remote_2 = double 'remote url', name: 'remote_2', url: 'url_2'

        allow(git).to receive(:remotes).and_return([remote_1, remote_2])

        expect(subject.remotes).to eq 'remote_1' => 'url_1', 'remote_2' => 'url_2'
      end
    end

    describe '#current_branch' do
      it 'returns current repository branch name' do
        branch_1 = double 'git branch', name: 'my_feature 1', current: false
        branch_2 = double 'git branch', name: 'my_feature 2', current: true
        branch_3 = double 'git branch', name: 'my_feature 3', current: false
        allow(git).to receive(:branches).and_return([branch_1, branch_2, branch_3])

        expect(subject.current_branch).to eq 'my_feature 2'
      end

      it 'raises exception of repository has no branches' do
        allow(git).to receive(:branches).and_return([])

        expect { subject.current_branch }.to raise_error ProjectReleaser::Project::Repository::RepositoryHasNoBranches
      end
    end

    describe '#checkout' do
      it 'checks out to branch by name' do
        expect(git).to receive(:checkout).with(:branch)

        subject.checkout :branch
      end

      it 'raises exception if the branch is missing' do
        allow(git).to receive(:checkout).with(:branch).and_raise(Git::GitExecuteError)
        expect { subject.checkout :branch }.to raise_error ProjectReleaser::Project::Repository::MissingBranch
      end
    end

    describe '#fetch_tags' do
      it 'fetches tags from all remotes' do
        remote_1 = double 'remote url', name: 'remote_1'
        remote_2 = double 'remote url', name: 'remote_2'
        allow(git).to receive(:remotes).and_return([remote_1, remote_2])

        expect(git).to receive(:fetch).with('remote_1', tags: true)
        expect(git).to receive(:fetch).with('remote_2', tags: true)

        subject.fetch_tags
      end
    end

    describe '#has_branch' do
      let(:branch) { double 'git branch', name: 'the_branch' }
      before :each do
        allow(git).to receive(:branches).and_return([branch])
      end

      it 'returns true if branch exists' do
        expect(subject.has_branch?(:the_branch)).to be_truthy
      end

      it 'returns false if branch exists' do
        expect(subject.has_branch?(:another_branch)).to be_falsy
      end
    end

    describe '#returning_to_current_branch' do
      let(:git) { double('git').as_null_object }
      let(:tmp_branch) { double 'git branch', name: :tmp_branch, current: false }
      let(:current_branch) { double 'git branch', name: :current_branch, current: true }

      before :each do
        allow(Git).to receive(:open).with(dir).and_return(git)
        allow(git).to receive(:branches).and_return([current_branch, tmp_branch])
      end

      it 'yields self' do
        subject.returning_to_current_branch do |obj|
          expect(obj).to be subject
        end
      end

      it 'checks out current branch after yielding block' do
        subject.returning_to_current_branch do
          # change current branch to something else
          allow(current_branch).to receive(:current).and_return(false)
          allow(tmp_branch).to receive(:current).and_return(true)

          expect(git).to_not have_received(:checkout)
        end

        expect(git).to have_received(:checkout).with(:current_branch)
      end
    end
  end
end
