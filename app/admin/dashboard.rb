ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Recent Records" do
          ul do
            Record.last(5).map do |record|
              li link_to(record.name, admin_record_path(record))
            end
          end
        end
      end
    end
  end 
end
