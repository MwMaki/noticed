module Noticed
  module Model
    extend ActiveSupport::Concern

    included do
      self.inheritance_column = nil

      serialize :params, Noticed::Coder

      belongs_to :recipient, polymorphic: true

      scope :newest_first, -> { order(created_at: :desc) }
    end

    module ClassMethods
      def mark_as_read!
        update_all(read_at: Time.current, updated_at: Time.current)
      end
    end

    # Rehydrate the database notification into the Notification object for rendering
    def to_notification
      @_notification ||= begin
                      instance = type.constantize.with(params)
                      instance.record = self
                      instance
                    end
    end

    def mark_as_read!
      update(read_at: Time.current)
    end

    def unread?
      !read?
    end

    def read?
      read_at?
    end
  end
end
