<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  before_action :authenticate_user!
  before_action :build_<%= singular_table_name %>, only: [:create]
  load_and_authorize_resource

  <%- unless options[:singleton] -%>
  def index
    @<%= plural_table_name %> = @<%= plural_table_name %>.paginate page: params[:page]
    respond_with @<%= plural_table_name %>
  end
  <%- end -%>

  def show
    respond_with @<%= singular_table_name %>
  end

  def new
    respond_with @<%= singular_table_name %>
  end

  def edit
  end

  def create
    @<%= orm_instance.save %>
    <%- if flash? -%>
    flash[:notice] = t('flash.actions.create.notice', resource_name: <%= class_name %>) if @<%= singular_table_name %>.valid?
    <%- end -%>
    respond_with @<%= singular_table_name %>
  end

  def update
    @<%= singular_table_name %>.update <%= "#{singular_table_name}_params" %>
    <%- if flash? -%>
    flash[:notice] = t('flash.actions.update.notice', resource_name: <%= class_name %>) if @<%= singular_table_name %>.valid?
    <%- end -%>
    respond_with @<%= singular_table_name %>
  end

  def destroy
    @<%= orm_instance.destroy %>
    respond_with @<%= singular_table_name %>
  end

  private

  def <%= "#{singular_table_name}_params" %>
    <%- if attributes_names.empty? -%>
    params[<%= ":#{singular_table_name}" %>]
    <%- else -%>
    params.require(<%= ":#{singular_table_name}" %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
    <%- end -%>
  end

  def build_<%= singular_table_name %>
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "#{singular_table_name}_params") %>
  end
end
<% end -%>
