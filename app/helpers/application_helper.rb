module ApplicationHelper
   # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "24-7 Online Clinic"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
end

module ActionView
  module Helpers
    class FormBuilder 
      def date_select(method, options = {}, html_options = {})
        existing_date = @object.send(method) 
        formatted_date = existing_date.to_date.strftime("%F") if existing_date.present?
        @template.content_tag(:div, :class => "input-group") do    
          text_field(method, :value => formatted_date, :class => "form-control datepicker", :"data-date-format" => "YYYY-MM-DD") +
          @template.content_tag(:span, @template.content_tag(:span, "", :class => "glyphicon glyphicon-calendar") ,:class => "input-group-addon")
        end
      end

      def datetime_select(method, options = {}, html_options = {})
        existing_time = @object.send(method) 
        formatted_time = existing_time.strftime("%B %-d, %Y %I:%M %P") if existing_time.present?
        @template.content_tag(:div, :class => "input-group") do    
          text_field(method, :value => formatted_time, :class => "form-control datetimepicker", :"data-date-format" => "MMMM D, YYYY hh:mm a") +
          @template.content_tag(:span, @template.content_tag(:span, "", :class => "glyphicon glyphicon-calendar") ,:class => "input-group-addon")
        end
      end

      def time_select(method, options = {}, html_options = {})
        existing_time = @object.send(method) 
        formatted_time = existing_time.strftime("%I:%M %P") if existing_time.present?
        @template.content_tag(:div, :class => "input-group") do    
          text_field(method, :value => formatted_time, :class => "form-control timepicker", :"data-date-format" => "hh:mm a") +
          @template.content_tag(:span, @template.content_tag(:span, "", :class => "glyphicon glyphicon-time") ,:class => "input-group-addon")
        end
      end

    end
  end
end