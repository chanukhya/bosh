require_relative '../../../../db_spec_helper'

module Bosh::Director
  describe 'change id from int to bigint variable_sets & variables' do
    let(:db) {DBSpecHelper.db}
    let(:migration_file) {'20170821144941_add_configs.rb'}
    let(:some_time) do
      Time.at(Time.now.to_i).utc
    end

    before do
      DBSpecHelper.migrate_all_before(migration_file)
    end

    describe 'cloud_configs' do
      it 'copies config data into config table and updates deployments table' do
        db[:cloud_configs] << { properties: 'old content', created_at: some_time }
        db[:deployments] << { name: 'fake-name', cloud_config_id: 1 }

        DBSpecHelper.migrate(migration_file)

        expect(db[:configs].count).to eq(1)
        deployment = db[:deployments].first
        expect(deployment[:cloud_config_id]).to be_nil
        new_config = db[:configs].where(id: deployment[:id]).first
        expect(new_config).to include({
          type: 'cloud',
          name: 'default',
          content: 'old content',
          created_at: some_time
         })
      end

      it 'changes the foreign key to config_id' do
        DBSpecHelper.migrate(migration_file)

        expect(db.foreign_key_list(:deployments).size).to eq(1)
        expect(db.foreign_key_list(:deployments).first).to eq({
          columns: [:config_id],
          table: :configs,
          key: nil,
          on_update: :no_action,
          on_delete: :no_action
         })
      end
    end

    # alter constraint on deployments (add column)
    # update deployment links...?
    # remove cc table
  end
end