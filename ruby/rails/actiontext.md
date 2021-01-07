---
title: Rails 6 action text
code: https://github.com/moonlight8978/practice/tree/master/rails/rails-6-discovering
---

# ActionText

## Save data

1. Request params with action text will look like this

```ruby
{
  content: "<div>asdfadsfda<figure data-trix-attachment=\"{&quot;contentType&quot;:&quot;text/javascript&quot;,&quot;filename&quot;:&quot;script.js&quot;,&quot;filesize&quot;:1217,&quot;sgid&quot;:&quot;BAh7CEkiCGdpZAY6BkVUSSIvZ2lkOi8vYXBwL0FjdGl2ZVN0b3JhZ2U6OkJsb2IvMz9leHBpcmVzX2luBjsAVEkiDHB1cnBvc2UGOwBUSSIPYXR0YWNoYWJsZQY7AFRJIg9leHBpcmVzX2F0BjsAVDA=--89f739b2109a23cb410bfdb2d0a9954bcae01719&quot;,&quot;url&quot;:&quot;http://localhost:60100/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBDQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--ace3e1f00074b3a489a892e68492b8372f799727/script.js&quot;}\" data-trix-content-type=\"text/javascript\" class=\"attachment attachment--file attachment--js\"><figcaption class=\"attachment__caption\"><span class=\"attachment__name\">script.js</span> <span class=\"attachment__size\">1.19 KB</span></figcaption></figure></div>"
}
```

2. Rails will try to find all attachments to attach to `ActiveText::RichText` record under `embeds` attribute.

```ruby
# https://github.com/rails/rails/blob/027085a5972a798cfea60f829a9edabbd67a2818/actiontext/app/models/action_text/rich_text.rb#L17
before_save do
  self.embeds = body.attachables.grep(ActiveStorage::Blob).uniq if body.present?
end
```

To achieve that.

- Rails will initialize ActionText::Content instance from params

```ruby
# https://github.com/rails/rails/blob/027085a5972a798cfea60f829a9edabbd67a2818/actiontext/app/models/action_text/rich_text.rb#L11
serialize :body, ActionText::Content
```

- Then, Rails looks up all DOM node (Nokogiri) with `ActionText::Attachment::SELECTOR`, with `sgid`, Rails can find appropriate ActiveStorage records.

```ruby
# https://github.com/rails/rails/blob/027085a5972a798cfea60f829a9edabbd67a2818/actiontext/lib/action_text/content.rb#L53
def attachables
  @attachables ||= attachment_nodes.map do |node|
    ActionText::Attachable.from_node(node)
  end
end

# https://github.com/rails/rails/blob/027085a5972a798cfea60f829a9edabbd67a2818/actiontext/lib/action_text/content.rb#L113
def attachment_nodes
  @attachment_nodes ||= fragment.find_all(ActionText::Attachment::SELECTOR)
end

# https://github.com/rails/rails/blob/027085a5972a798cfea60f829a9edabbd67a2818/actiontext/lib/action_text/attachable.rb#L10
def from_node(node)
  if attachable = attachable_from_sgid(node["sgid"])
    attachable
  elsif attachable = ActionText::Attachables::ContentAttachment.from_node(node)
    attachable
  elsif attachable = ActionText::Attachables::RemoteImage.from_node(node)
    attachable
  else
    ActionText::Attachables::MissingAttachable
  end
end
```

3. Rails save `ActionText::RichText` record with body look like:

```ruby
body = '<div>asdfadsfda<action-text-attachment sgid="BAh7CEkiCGdpZAY6BkVUSSIvZ2lkOi8vYXBwL0FjdGl2ZVN
0b3JhZ2U6OkJsb2IvMz9leHBpcmVzX2luBjsAVEkiDHB1cnBvc2UGOwBUSSIPYXR0YWNoYWJsZQY7AFRJIg9leHBpcmVzX2F0BjsAVDA=-
-89f739b2109a23cb410bfdb2d0a9954bcae01719" content-type="text/javascript" url="http://localhost:60100/rail
s/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBDQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--a
ce3e1f00074b3a489a892e68492b8372f799727/script.js" filename="script.js" filesize="1217"></action-text-atta
chment></div>'
```

To achieve this, Rails minify `action-text-attachment` directive

```ruby
# https://github.com/rails/rails/blob/027085a5972a798cfea60f829a9edabbd67a2818/actiontext/lib/action_text/attachments/minification.rb#L9
def fragment_by_minifying_attachments(content)
  Fragment.wrap(content).replace(ActionText::Attachment::SELECTOR) do |node|
    node.tap { |n| n.inner_html = "" }
  end
end
```

4. To show `rich_text` in view, Rails will expand `action-text-attachment` directive by using this method

```ruby
# https://github.com/rails/rails/blob/027085a5972a798cfea60f829a9edabbd67a2818/actiontext/app/helpers/action_text/content_helper.rb#L20
def render_action_text_attachments(content)
  content.render_attachments do |attachment|
    unless attachment.in?(content.gallery_attachments)
      attachment.node.tap do |node|
        node.inner_html = render(attachment, in_gallery: false).chomp
      end
    end
  end.render_attachment_galleries do |attachment_gallery|
    render(layout: attachment_gallery, object: attachment_gallery) do
      attachment_gallery.attachments.map do |attachment|
        attachment.node.inner_html = render(attachment, in_gallery: true).chomp
        attachment.to_html
      end.join("").html_safe
    end.chomp
  end
end
```
