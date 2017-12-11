ActiveAdmin.register Package do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  filter :authors, as: :select
  filter :maintainers, as: :select
  filter :name
  filter :version
  filter :date_publication
  filter :title
  filter :description

  show do
    attributes_table do
      row :name
      row :version
      row :date_publication
      row :title
      row :description
    end
    active_admin_comments
  end

  index do
    selectable_column
    column :id do |package|
      link_to package.id, admin_package_path(package)
    end
    column :name
    column :version
    column :date_publication
    column :title
    column :description
    actions
  end

  action_item :download, only: :show do
    link_to 'Download', download_admin_package_path
  end

  member_action :download do
    send_data resource.file_content, filename: resource.file_name
  end

end
