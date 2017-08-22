require_relative '../../../../db_spec_helper'

module Bosh::Director
  describe 'remove old cloud configs' do
    let(:db) { DBSpecHelper.db }
    let(:migration_file) { '20170821144941_add_configs_spec.rb' }

    before { DBSpecHelper.migrate_all_before(migration_file) }

    it 'drops the cloud_configs table' do
      DBSpecHelper.migrate(migration_file)

      expect(db.table_exists?(:cloud_configs)).to eq(false)
    end

    it 'removes the foreign from deployments' do
      expect(db.foreign_key_list(:deployments).size).to eq(1)
      expect(db.foreign_key_list(:deployments).first).to include(
        columns: [:cloud_config_id],
        table: :configs
      )
    end
  end
end