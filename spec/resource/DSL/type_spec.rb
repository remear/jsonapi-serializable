require 'spec_helper'

describe JSONAPI::Serializable::ResourceDSL, '.type' do
  it 'accepts a string' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
    end
    resource = klass.new(object: User.new)

    expect(resource.jsonapi_type).to eq('foo')
  end

  it 'accepts a block' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type { 'foo' }
    end
    resource = klass.new(object: User.new)

    expect(resource.jsonapi_type).to eq('foo')
  end
end