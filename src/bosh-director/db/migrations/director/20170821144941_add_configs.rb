Sequel.migration do
  change do
    adapter_scheme = self.adapter_scheme

    create_table :configs do
      primary_key :id

      String :name, :null => false
      String :type, :null => false

      if [:mysql2, :mysql].include?(adapter_scheme)
        longtext :content
      else
        text :content
      end

      Time :created_at, null: false

      TrueClass :deleted, default: false
    end

    alter_table :deployments do
      add_foreign_key :config_id, :configs
    end

    self[:cloud_configs].each do |cloud_config|
      new_config = self[:configs].insert({
        type: 'cloud',
        name: 'default',
        content: cloud_config[:properties],
        created_at: cloud_config[:created_at]
      })

      self[:deployments].where(cloud_config_id: cloud_config[:id]).update(
        config_id: new_config
      )
    end

    alter_table :deployments do
      drop_foreign_key :cloud_config_id
    end
  end
end
