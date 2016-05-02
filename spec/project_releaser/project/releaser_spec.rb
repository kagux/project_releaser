require 'spec_helper'

describe ProjectReleaser::Project::Releaser do
  let(:repository) { double 'repository' }
  let(:yielded_repository) { double 'repository' }
  let(:subject) { ProjectReleaser::Project::Releaser.new repository }

  before :each do
    allow(repository).to receive(:returning_to_current_branch).and_yield(yielded_repository)
  end

  it 'releases project with provided version name' do
    allow(yielded_repository).to receive(:has_branch?).with(:develop).and_return(true)
    expect(yielded_repository).to receive(:pull).with([:master, :develop]).ordered
    expect(yielded_repository).to receive(:merge).with(:master, :develop).ordered
    expect(yielded_repository).to receive(:push).with(:master, 'v2.3.5').ordered

    subject.release 'v2.3.5'
  end

  it 'doesnt pull and skips merging when there is no develop branch' do
    allow(yielded_repository).to receive(:has_branch?).with(:develop).and_return(false)
    expect(yielded_repository).to receive(:pull).with([:master]).ordered
    expect(yielded_repository).not_to receive(:merge)
    expect(yielded_repository).to receive(:push).with(:master, 'v1.2.4').ordered

    subject.release 'v1.2.4'
  end
end
