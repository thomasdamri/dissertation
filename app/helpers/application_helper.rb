module ApplicationHelper

  def link_to_add_fields(name, f, association, field_partial)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(field_partial, f: builder)
    end
    link_to name, '#', class: 'add_fields btn btn-primary', data: {id: id, fields: fields.gsub("\n", "")}
  end

end
