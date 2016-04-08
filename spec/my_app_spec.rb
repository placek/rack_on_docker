require_relative 'spec_helper'

describe 'My Sinatra Application' do
  context 'accessing the home page' do
    before { get '/' }
    it { expect(last_response).to be_ok }
  end
end
