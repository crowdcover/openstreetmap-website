class CreateTiles < ActiveRecord::Migration
  def change
    create_table :tiles do |t|
      t.string  :code
      t.string  :keyid
      t.string  :name
      t.string  :attribution
      t.string  :url
      t.string  :subdomains
      t.string  :base_layer
    end
  end
end
