;;;; model.lisp

(in-package :cl-user)

(defpackage fullstackwiki.model
  (:use :cl :sxql)
  (:import-from :fullstackwiki.db
                :db
                :with-connection
                :with-transaction) 
  (:import-from :datafly
                :execute
                :retrieve-all
                :retrieve-one)
  (:export :create-tables
           :find-user
           :add-user
           :authenticate-user
           :add-page
           :get-latest-page
           :get-latest-pages-titles
           :get-latest-pages-by-user
           :get-sorted-pages
           :count-pages
           :nth-page-revision))

(in-package :fullstackwiki.model)

;;; User model

(defun create-user-table ()
  "Create user table if it doesn't exist yet."
  (with-connection (db)
    (execute
     (create-table (:user :if-not-exists t)
         ((id :type 'serial :primary-key t)
          (username :type 'text :not-null t :unique t)
          (email :type 'text :not-null t :unique t)
          (password :type 'text :not-null t))))))

(defun add-user (username email password)
  "add user record to database."
  (with-connection (db)
    (execute
     (insert-into :user
       (set= :username username
             :email email
             :password (cl-pass:hash password))))))

(defun find-user-by-username (username)
  "lookup user record by username."
  (with-connection (db)
    (retrieve-one
     (select :*
       (from :user)
       (where (:= :username username))))))

(defun find-user-by-email (email)
  "lookup user record by email."
  (with-connection (db)
    (retrieve-one
     (select :* (from :user)
             (where (:= :email email))))))

(defun find-user (username-or-email)
  "lookup user record by username or email."
  (or (find-user-by-username username-or-email)
      (find-user-by-email username-or-email)))

(defun authenticate-user (username-or-email password)
  "Lookup user record and validate password. Returns two values:
   1st value, was password correct T or NIL
   2nd value, was user found, T or NIL
Example:
   (VALUES NIL NIL) -> user not found
   (VALUES NIL T) -> user found, but wrong password
   (VALUES T T) -> password correct"
  (let ((password-hash (getf (find-user username-or-email) :password)))
    (if password-hash 
        (values (cl-pass:check-password password password-hash) t)
        (values nil nil))))

;;; Page model

(defun create-page-table ()
  "Create page table if it doesn't exist yet."
  (with-connection (db)
    (execute
     (create-table (:page if-not-exists t)
         ((id :type 'serial :primary-key t)
          (title :type 'text :not-null t)
          (author-id :type 'integer :not-null t)
          (content :type 'text :not-null t)
          (date :type 'timestamp :not-null t)
          (latest :type 'boolean :not-null t)) ;; is this the latest version of the page
       (foreign-key '(:author-id) :references '(:user :id))))))

(defun add-page (title author content)
  "Add page to database. Mark it as \"latest: true\", mark previous \"latest: false\"."
  (with-transaction (db)
    (execute
     (update :page
       (set= :latest "false")
       (where (:and
               (:= :title title)
               (:= :latest "true")))))
    (execute
     (insert-into :page
       (set= :title title
             :author-id (getf (find-user author) :id)
             :content content
             :date (local-time:now)
             :latest "true")))))

(defun get-latest-page (title)
  "Get the latest version of a page by TITLE."
  (with-connection (db)
    (retrieve-one
     (select :*
       (from :page)
       (where (:and (:= :title title)
                    (:= :latest "true")))))))

(defun get-latest-pages-titles ()
  "Get the titles of latest versions of pages"
  (with-connection (db)
    (retrieve-all
     (select :title
       (from :page)
       (where (:= :latest "true"))
       (order-by (:desc :date))))))

(defun get-latest-pages-by-user (username)
  "Get the latest versions of all pages by USERNAME."
  (with-connection (db)
    (retrieve-all
     (select (:page.id :title :username :content :date :latest)
       (from :page :user)
       (where (:and (:= :user.id :author-id)
                    (:= :user.username username)
                    (:= :latest "true")))))))

(defun get-sorted-pages (title)
  "Get all versions of a page by TITLE, sorted by it's timestamp in descending order, newest first."
  (with-connection (db)
    (retrieve-all
     (select :*
       (from :page)
       (where (:= :title title))
       (order-by (:desc :date))))))

(defun count-pages (title)
  "Count the number of versions a page has."
  (with-connection (db)
    (getf (retrieve-one
           (select (:title (:count :*))
             (from :page)
             (where (:= :title title))
             (group-by :title)))
          :count)))

(defun nth-page-revision (title n)
  "Get the nth version of a page, sorted by its DATE."
  (nth n (get-sorted-pages title)))

;;; 

(defun create-tables ()
  "Create all tables, if they don't exist already."
  (create-user-table)
  (create-page-table))
