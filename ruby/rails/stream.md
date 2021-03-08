---
title: Rails Streaming
code: https://github.com/moonlight8978/rails-exploration/tree/streaming
---

* Streaming: https://api.rubyonrails.org/classes/ActionController/Streaming.html
* Live: https://api.rubyonrails.org/classes/ActionController/Live.html

#### Streaming

* Usage

  ```ruby
  class PostsController
    def index
      response.headers["Last-Modified"] = Time.current.httpdate
      render stream: true
    end
  end
  ```

* By default:

  * Rails render template first, and then the layout. 
  * The response is sent to the client after the whole template is rendered, all queries are made, and the layout is processed.

* `Streaming` reverts the rendering flow

  * Render template first
  * Stream each part of the layout as they are processed

* When request

  * Server will returns the layout first (the header in most time), with response headers, ...

    ```html
    curl -i localhost:3000
    HTTP/1.1 200 OK
    X-Frame-Options: SAMEORIGIN
    X-XSS-Protection: 1; mode=block
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Permitted-Cross-Domain-Policies: none
    Referrer-Policy: strict-origin-when-cross-origin
    Last-Modified: Mon, 08 Mar 2021 08:27:00 GMT
    Cache-Control: no-cache
    Transfer-Encoding: chunked
    Vary: Accept
    Content-Type: text/html; charset=utf-8
    X-Request-Id: 333db74f-4c19-49a3-a141-1780b7205b32
    X-Runtime: 0.003117
    
    <!DOCTYPE html>
    <html>
      <head>
        <title>App</title>
        <meta name="viewport" content="width=device-width,initial-scale=1">
      </head>
      <body>
    ```

  * Response body will be streamed later after the template is ready

    ```html
    		<span>1</span>
      0
      <span>2</span>
      0
      <span>3</span>
      0
      </body>
    </html>
    ```

  * If error occurred, server will return a script to redirect to 500 template

    ```html
    <script>window.location = /500.html</script>
    ```

* Notes:
  * Instance variable won't work inside the layout. Use `content_for`, `provide`, `yield` instead
  * `provide` is called once for each part, `content_for` is called multiple times, and are concatenated
  * Apply to template only, XML, JSON won't work
* Use case
  * Render large data table

#### ActionController::Live

* Usage

  ```ruby
  class LivesController < ApplicationController
    include ActionController::Live
  
    def show
      disposition = ActionDispatch::Http::ContentDisposition.format(disposition: "attachment", filename: "live.csv")
      response.headers["Content-Disposition"] = disposition
      response.headers["Content-Type"] = "text/csv"
      response.headers["Last-Modified"] = Time.current.httpdate
      100.times {
        response.stream.write CSV.generate_line(["1", "title", "content"])
        sleep 0.05
      }
    ensure
      response.stream.close
    end
  end
  ```

* Note
  * Stream must be close after processed, otherwise the socket will leave open
  * The response headers will not available until the stream is over
  * Need HTTP 1.1 or higher

* Request

  ```txt
  HTTP/1.1 200 OK
  Server: nginx/1.19.7
  Date: Mon, 08 Mar 2021 08:54:11 GMT
  Content-Type: text/csv
  Transfer-Encoding: chunked
  Connection: keep-alive
  Content-Disposition: attachment; filename="live.csv"; filename*=UTF-8''live.csv
  Last-Modified: Mon, 08 Mar 2021 08:54:11 GMT
  Cache-Control: no-store, must-revalidate, private, max-age=0
  X-Request-Id: 1649bd8c-a17f-4413-9406-469aa0a75e9d
  X-Runtime: 0.004780
  X-MiniProfiler-Original-Cache-Control: no-cache
  X-MiniProfiler-Ids: 9dfl9qzc7op6ckrts566,su3q84fa2xlystr0tz7s,2eqh0hmva589dxr9zzy4,7wbhxgbcz4oel99bm67x,vtiyjx7ucywbv85q8jss
  Set-Cookie: __profilin=p%3Dt; path=/; HttpOnly; SameSite=Lax
  
  1,title,content
  1,title,content
  1,title,content
  1,title,content
  1,title,content
  ```

  * The body is concatenated overtime

#### ActionController::Metal enumerable response_body

* Usage

  ```ruby
  disposition = ActionDispatch::Http::ContentDisposition.format(disposition: "attachment", filename: "chunked.csv")
  
  response.headers["Content-Disposition"] = disposition
  response.headers["Content-Type"] = "text/csv"
  # Tell Rack to stream the content
  response.headers.delete("Content-Length")
  # Don't cache anything from this generated endpoint
  response.headers["Cache-Control"] = "no-cache"
  # this is a hack to preven middleware from buffering
  response.headers["Last-Modified"] = Time.current.httpdate
  # Don't buffer when going through proxy servers
  response.headers["X-Accel-Buffering"] = "no"
  
  self.response_body = Enumerator.new do |io|
    100.times do
      io << CSV.generate_line(["1", "title", "content"])
      sleep 0.05
    end
  end
  ```

* Note:

  * Does not require anything special

* Request

  ```txt
  curl -i localhost/chunk                                                                                                                                            [6804b94] 
  HTTP/1.1 200 OK
  Server: nginx/1.19.7
  Date: Mon, 08 Mar 2021 08:56:24 GMT
  Content-Type: text/csv
  Transfer-Encoding: chunked
  Connection: keep-alive
  X-Frame-Options: SAMEORIGIN
  X-XSS-Protection: 1; mode=block
  X-Content-Type-Options: nosniff
  X-Download-Options: noopen
  X-Permitted-Cross-Domain-Policies: none
  Referrer-Policy: strict-origin-when-cross-origin
  Content-Disposition: attachment; filename="chunked.csv"; filename*=UTF-8''chunked.csv
  Cache-Control: no-store, must-revalidate, private, max-age=0
  Last-Modified: Mon, 08 Mar 2021 08:56:24 GMT
  X-Request-Id: 110883ba-f7d6-47d6-b8f8-d43080362386
  X-Runtime: 0.017299
  X-MiniProfiler-Original-Cache-Control: no-cache
  X-MiniProfiler-Ids: 4909w92x1300zeq1kjfw,su3q84fa2xlystr0tz7s,2eqh0hmva589dxr9zzy4,7wbhxgbcz4oel99bm67x,vtiyjx7ucywbv85q8jss,9dfl9qzc7op6ckrts566
  Set-Cookie: __profilin=p%3Dt; path=/; HttpOnly; SameSite=Lax
  
  1,title,content
  1,title,content
  1,title,content
  1,title,content
  1,title,content
  1,title,content
  1,title,content
  1,title,content
  1,title,content
  1,title,content
  1,title,content
  ```

  * The body is concatenated overtime

#### Note

* Rails using Rack, which has the following code

  ```ruby
  # https://github.com/rack/rack/blob/138cba2f49d5c18e91b3dc377a83b9ce1fb70094/lib/rack/etag.rb#L30
  def call
    if etag_status?(status) && etag_body?(body) && !skip_caching?(headers)
    	original_body = body
      digest, new_body = digest_body(body)
      # ...
  	end
  end
  
  def skip_caching?(headers)
    headers.key?(ETAG_STRING) || headers.key?('Last-Modified')
  end
  ```

  Even we use Enumerable, the body is still preprocessed to generate the ETag. So, when stream response, we must add `Last-Modified` header

  ```ruby
  response.headers["Last-Modified"] = Time.current.httpdate
  ```

* Nginx will buffer the response (wait until the response is completed),  set `X-Accel-Buffering` header to `no` to disable it

  ```ruby
  response.headers["X-Accel-Buffering"] = "no"
  ```

  