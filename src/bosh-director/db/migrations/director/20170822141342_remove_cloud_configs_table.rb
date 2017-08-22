Sequel.migration do
  change do
    alter_table :deployments do
      drop_foreign_key :cloud_config_old_id
    end

    drop_table :cloud_configs
  end
end