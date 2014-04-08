ThinkingSphinx::Index.define :fun, with: :active_record do
  indexes content.title, as: :title, sortable: true
  indexes content.cached_tag_list, as: :tags

  has '(CASE WHEN content_type = "Image" THEN 0 WHEN content_type = "Video" THEN 1 WHEN content_type = "Post" THEN 2 END)', as: :type, type: :integer

  polymorphs content, to: %w(Image Video Post)
end