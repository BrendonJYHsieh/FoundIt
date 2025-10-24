module ApplicationHelper
  def valid_image_url?(url)
    return false if url.blank?
    
    # Check if URL looks like an image
    image_extensions = %w[.jpg .jpeg .png .gif .webp .bmp]
    uri = URI.parse(url)
    
    # Basic URL validation
    return false unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    
    # Check file extension or common image hosting patterns
    path = uri.path.downcase
    host = uri.host.downcase
    
    # Allow common image hosting services even without file extensions
    image_hosts = %w[postimg.cc drive.google.com dropbox.com]
    return true if image_hosts.any? { |host_pattern| host.include?(host_pattern) }
    
    # Check file extension for other URLs
    image_extensions.any? { |ext| path.end_with?(ext) }
  rescue URI::InvalidURIError
    false
  end

  def clean_image_urls(urls_string)
    return [] if urls_string.blank?
    
    urls = urls_string.split(/[\n,]+/).map(&:strip).reject(&:blank?)
    urls.select { |url| valid_image_url?(url) }
  end
end
