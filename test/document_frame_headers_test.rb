require "minitest/autorun"
require_relative "../lib/document_frame_headers"

class DocumentFrameHeadersTest < Minitest::Test
  def response(path: "/rails/active_storage/disk/signed/report.pdf", type: "application/pdf", status: 200, method: "GET")
    headers = {
      "content-type" => type,
      "x-frame-options" => "SAMEORIGIN",
      "content-security-policy" => "object-src 'none'; frame-ancestors 'self'; base-uri 'self'"
    }
    body = [ "file bytes" ]
    app = DocumentFrameHeaders.new(->(_) { [ status, headers, body ] },
      allowed_origins: [ "https://prod-era.era.gov.et" ])
    result = app.call("PATH_INFO" => path, "REQUEST_METHOD" => method)
    assert_same body, result.last
    assert_equal "SAMEORIGIN", headers["x-frame-options"], "must not mutate original headers"
    result
  end

  def test_pdf_allows_frontend_and_preserves_other_directives
    status, headers = response
    assert_equal 200, status
    refute headers.key?("x-frame-options")
    assert_equal "object-src 'none'; base-uri 'self'; frame-ancestors 'self' https://prod-era.era.gov.et",
      headers["content-security-policy"]
  end

  def test_range_and_head_responses_allow_pdf_embedding
    [ { status: 206 }, { method: "HEAD" }, { type: "application/pdf; charset=binary" },
      { path: "/rails/active_storage/blobs/proxy/signed/report.pdf" } ].each do |options|
      refute response(**options)[1].key?("x-frame-options")
    end
  end

  def test_admin_errors_redirects_and_non_pdf_files_keep_protection
    [ { path: "/admin" }, { path: "/" }, { status: 404 }, { status: 302 },
      { type: "text/html" }, { type: "application/msword" }, { method: "POST" } ].each do |options|
      headers = response(**options)[1]
      assert_equal "SAMEORIGIN", headers["x-frame-options"]
      assert_includes headers["content-security-policy"], "frame-ancestors 'self';"
    end
  end

  def test_rejects_wildcards_paths_and_directive_injection
    [ "*", "https://*.example.com", "https://example.com/", "https://example.com;", "'none'" ].each do |origin|
      assert_raises(ArgumentError, URI::InvalidURIError) do
        DocumentFrameHeaders.new(nil, allowed_origins: [ origin ])
      end
    end
  end
end
