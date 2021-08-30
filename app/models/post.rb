class Post < ApplicationRecord
  has_rich_text :content

  validates :title, length: { maximum: 32 }, presence: true

  validate :validate_content_length
  validate :attachable_byte_size
  validate :attachable_file_length

  MAX_CONTENT_LENGTH = 250
  ONE_KILOBYTE = 1024
  MEGA_BYTES = 6
  MAX_CONTENT_ATTACHMENT_BYTE_SIZE = MEGA_BYTES * 1_000 * ONE_KILOBYTE
  FILE_LENGTH = 4

  private

  def validate_content_length
    length = content.to_plain_text.length
    if length > MAX_CONTENT_LENGTH
      errors.add(
        :content,
        :too_long,
        max_content_length: MAX_CONTENT_LENGTH,
        length: length,
        )
    end
  end

  def attachable_byte_size
    content.body.attachables.grep(ActiveStorage::Blob).each do |attachable|
      if attachable.byte_size > MAX_CONTENT_ATTACHMENT_BYTE_SIZE
        errors.add(
          :base,
          :content_attachment_byte_size_is_too_big,
          max_content_attachment_mega_byte_size: MEGA_BYTES,
          bytes: attachable.byte_size,
          max_bytes: MAX_CONTENT_ATTACHMENT_BYTE_SIZE
        )
      end
    end
  end

  def attachable_file_length
    current_length = content.body.attachables.grep(ActiveStorage::Blob).length
    if current_length > FILE_LENGTH
      errors.add(
        :base,
        :attachable_file_length,
        file_length: FILE_LENGTH,
        current_length: current_length
      )
    end
  end
end