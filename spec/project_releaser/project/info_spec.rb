require 'spec_helper'
require 'json'

describe ProjectReleaser::Project::Info do

  let(:repository) { double 'git' }
  let(:subject) { ProjectReleaser::Project::Info.new repository }

  describe '#name' do
    it 'gets name from last remote url' do
      remotes = {
        :origin => 'git@git.example.com/hello.git',
        :upstream => 'git@git.example.com/goodbye.git'
      }
      allow(repository).to receive(:remotes).and_return(remotes)

      expect(subject.name).to eq 'goodbye'
    end

    it 'returns unknown when there are no remotes' do
      remotes = {}
      allow(repository).to receive(:remotes).and_return(remotes)

      expect(subject.name).to eq 'unknown'
    end
  end

  describe '#current_version' do
    it 'fetches remotes and returns current version' do
      allow(repository).to receive(:current_version).and_return({ :major => 2, :minor => 3, :patch => 3 })

      allow(repository).to receive(:fetch_tags) do
        allow(repository).to receive(:current_version).and_return({ :major => 2, :minor => 3, :patch => 4 })
      end

      expect(subject.current_version).to eq 'v2.3.4'
    end
  end

  describe '#next_version' do

    before :each do
      allow(repository).to receive(:current_version).and_return({ :major => 2, :minor => 3, :patch => 4 })
    end

    it 'returns next patch version' do
      expect(subject.next_version :patch).to eq 'v2.3.5'
    end

    it 'returns next minor version' do
      expect(subject.next_version :minor).to eq 'v2.4.0'
    end

    it 'returns next major version' do
      expect(subject.next_version :major).to eq 'v3.0.0'
    end

    it 'returns next patch version by default' do
      expect(subject.next_version).to eq 'v2.3.5'
    end

    it 'returns next patch version for nil version_type' do
      expect(subject.next_version nil).to eq 'v2.3.5'
    end

    it 'accepts version type as string' do 
      expect(subject.next_version 'major').to eq 'v3.0.0'
    end

    it 'returns version_type if it is exact version number' do
      expect(subject.next_version 'v7.10.5').to eq 'v7.10.5' 
    end

    it 'returns version_type prefixed with v if it is exact version number' do
      expect(subject.next_version '7.10.5').to eq 'v7.10.5' 
    end

    it 'raises error when version is invalid' do
      expect{subject.next_version 'death star'}.to raise_error
    end
  end
end
