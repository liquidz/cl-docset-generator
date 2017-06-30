(in-package :cl-user)
(defpackage docset-generator.template
  (:use :cl)
  (:export
    :render-info.plist
    :render-insert-search-index))
(in-package :docset-generator.template)

(mustache:define
  info.plist
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
  <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
  <plist version=\"1.0\">
  <dict>
  <key>CFBundleIdentifier</key>   <string>{{id}}</string>
  <key>CFBundleName</key>         <string>{{name}}</string>
  <key>DocSetPlatformFamily</key> <string>{{family}}</string>
  <key>isDashDocset</key>         <true/>
  <key>isJavaScriptEnabled</key>  <true/>
  </dict>
  </plist>")

(defparameter *search-index-schema*
  "CREATE TABLE searchIndex( id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);")

(mustache:define
  insert-search-index
  "INSERT OR IGNORE INTO
  searchIndex(name, type, path)
  VALUES ('{{name}}', '{{type}}', '{{path}}');")

(defmacro to-str (body)
  `(with-output-to-string (mustache:*output-stream*)
     ,body))

(defun render-info.plist (context)
  (to-str (info.plist context)))

(defun render-insert-search-index (context)
  (to-str (info.plist context)))
