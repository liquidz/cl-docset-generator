(in-package :cl-user)
(defpackage docset-generator
  (:use :cl)
  (:export
    :docset
    :docset-record
    :add-record
    :generate))
(in-package :docset-generator)

(defclass docset ()
  ((id       :initform ""     :initarg :id)
   (name     :initform ""     :initarg :name)
   (family   :initform ""     :initarg :family)
   (records  :initform nil    :initarg :records)
   (icon     :initform nil    :initarg :icon)
   (base-dir :initform "/tmp" :initarg :base-dir)))

(defclass docset-record ()
  ((name   :initform "" :initarg :name)
   (type   :initform "" :initarg :type)
   (prefix :initform "" :initarg :prefix)
   (body   :initform "" :initarg :body)))

(defun join (coll &optional (sep ""))
  (reduce (lambda (res s) (format nil "~A~A~A" res sep s)) coll))

(defun path-join (&rest coll)
  (join coll (uiop::directory-separator-for-host)))

(defun normalize-path (s)
  (ppcre::regex-replace-all "[*@/ ]" s ""))

(defmethod add-record ((ds docset) (dr docset-record))
  "Add docset-record instance to docset instance."
  (alexandria:appendf (slot-value ds 'records) (list dr)))

(defmethod contents-dir ((ds docset))
  (let* ((name (slot-value ds 'name))
         (name (format nil "~A.docset" name)))
    (path-join (slot-value ds 'base-dir) name "Contents")))

(defmethod resource-dir ((ds docset))
  (path-join (contents-dir ds) "Resources"))

(defmethod document-dir ((ds docset))
  (path-join (resource-dir ds) "Documents"))

(defmethod filename ((dr docset-record))
  (let ((ls (list (slot-value dr 'prefix)
                  (slot-value dr 'type)
                  (slot-value dr 'name) "html")))
    (join (mapcar #'normalize-path ls) ".")))

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

(defmethod generate-info.plist ((ds docset))
  (alexandria:write-string-into-file
    (to-str
      (info.plist
        (list (cons :id (slot-value ds 'id))
              (cons :name (slot-value ds 'name) )
              (cons :family (slot-value ds 'family)))))
    (path-join (contents-dir ds) "Info.plist")
    :if-exists :supersede))

(defmethod generate-document-files ((ds docset))
  (let ((records (slot-value ds 'records))
        (document-dir (document-dir ds)))
    (loop for record in records
          do (alexandria:write-string-into-file
               (slot-value record 'body)
               (path-join document-dir (filename record))
               :if-exists :supersede))))

(defmethod generate-docset.dsidx ((ds docset))
  (let ((records (slot-value ds 'records))
        (db-path (path-join (resource-dir ds) "docSet.dsidx")))
    (uiop:delete-file-if-exists db-path)
    (dbi:with-connection (conn :sqlite3 :database-name db-path)
      (dbi:execute (dbi:prepare conn *search-index-schema*))
      (dbi:with-transaction conn
        (loop for record in records
              do (dbi:do-sql conn (to-str (insert-search-index
                                            (list (cons :name (slot-value record 'name))
                                                  (cons :type (slot-value record 'type))
                                                  (cons :path (filename record)))))))))))

(defmethod generate ((ds docset))
  (ensure-directories-exist (format nil "~A/" (document-dir ds)))
  (generate-info.plist ds)
  (generate-document-files ds)
  (generate-docset.dsidx ds))
