require 'spec_helper'

describe ProjectReleaser::Project::Updater do
  let(:repository) { double 'repository' }
  let(:yielded_repository) { double 'repository' }
  let(:subject) { ProjectReleaser::Project::Updater.new repository }

  it 'updates master and develop branches from all remotes' do
    allow(repository).to receive(:returning_to_current_branch).and_yield(yielded_repository)
    expect(yielded_repository).to receive(:pull).with([:master, :develop])

    subject.update
  end
end
