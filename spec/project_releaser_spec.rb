require 'spec_helper'
describe ProjectReleaser do
  let(:subject) {ProjectReleaser}

  it 'is configurable' do
    subject.configure do |c|
      c.key_a = :value_a
      c.key_b = :value_b
    end

    expect(subject.configuration.key_a).to eq :value_a
    expect(subject.configuration.key_b).to eq :value_b
  end
end
