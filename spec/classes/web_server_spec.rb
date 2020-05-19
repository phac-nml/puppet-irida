require 'spec_helper'

describe 'irida::web_server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_service('httpd.service') }
    end
  end
end
