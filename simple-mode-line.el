;;; simple-mode-line.el --- Simplified Mode Line for Emacs

;; Author: Anan Mikami <lateau at gmail.com>
;; Keywords: mode-line, color
;; Version: 0.4
;; URL: https://github.com/lateau/simple-mode-line.el

;;; Commentary:

;; This simplified mode line is adjusted to *white* themes.
;; Use this mode line with a white theme is highly recommended
;; but some colors are modifiable to fit your favorite theme.
;; For more description see below defcustom macros.
;;
;; Add this line in your .emacs file to enable simple-mode-line:
;;   (activate-simple-mode-line t)
;;
;; To display global-mode-string informations:
;;   (setq simple-mode-line-display-global-mode-string t)
;;
;; Adjust number of directories to display:
;;   (setq simple-mode-line-dir-lmax 1)
;;   (setq simple-mode-line-dir-rmax 3)
;;
;; Use set-face-attribute to customize simple mode line's faces:
;;   * mode-line-input-method-title-face
;;   * mode-line-editable-face
;;   * mode-line-read-only-face
;;   * mode-line-modified-face
;;   * mode-line-80+-face
;;   * mode-line-position-face
;;

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

(defgroup simple-mode-line nil
  "Simplified Mode Line.")

(defcustom simple-mode-line-display-global-mode-string nil
  "Hide global-mode-string in default."
  :group 'simple-mode-line
  :type 'boolean)

(defcustom simple-mode-line-dir-lmax 1
  "Set how many directories display."
  :group 'simple-mode-line
  :type 'integer)

(defcustom simple-mode-line-dir-rmax 3
  "Set how many directories display."
  :group 'simple-mode-line
  :type 'integer)

(defun simple-path (truepath lmax rmax)
  "Generates simplified path from file path"
  (if truepath
      (let ((path (cdr (split-string truepath "/")))
            (result ""))
        (if (<= (length path) (+ lmax rmax))
            (let ((file-name-length (length (car (reverse path)))))
              (substring truepath 0 (- (length truepath) file-name-length)))
          (let ((start-point (substring truepath 0 1))
                (lcount 0)
                (rcount 0))
            (while (and path (< lcount lmax))
              (setq result (concat result "/" (car path)))
              (setq lcount (1+ lcount))
              (setq path (cdr path)))
            (setq path (last path (+ rmax 1)))
            (setq result (concat result "/..."))
            (while (and path (< rcount rmax))
              (setq result (concat result "/" (car path)))
              (setq rcount (1+ rcount))
              (setq path (cdr path)))
            (if (string= start-point "~")
                (setq result (concat "~" result)))
            (setq result (concat result "/"))
            result)))
    ""))

(setq simple-mode-line-format
   '(;; input method
     (:propertize (:eval (if current-input-method-title current-input-method-title "")) 'face mode-line-input-method-title-face)
     " "
     "%z"
     " "
     ;; Display current buffer file path or name
     (:eval (simple-path buffer-file-truename
                         simple-mode-line-dir-lmax
                         simple-mode-line-dir-rmax))
     (:eval
      (cond (buffer-read-only
             (propertize "%b" 'face 'mode-line-read-only-face))
            ((buffer-modified-p)
             (propertize "%b" 'face 'mode-line-modified-face))
            (t (propertize "%b" 'face 'mode-line-editable-face))))
     " "
     ;; is remote or local?
     (:eval (if buffer-file-name mode-line-remote ""))
     (:eval (if buffer-file-name " " ""))
     ;; Display a current cursor position
     (:propertize (:eval (if buffer-file-name "%l" "")) 'face mode-line-position-face)
     (:eval (propertize (if buffer-file-name ":%c " "")
                        'face
                        (if (>= (current-column) 80) 'mode-line-80+-face
                          'mode-line-position-face)))
     ;; Other buffer file infomations
     (:eval (if buffer-file-name "%p " ""))
     (:eval (if buffer-file-name "%I " ""))
     ;; vc mode
     (vc-mode vc-mode)
     " "
     ;; Major mode
     "%m"
     ;; global-mode-string
     (:eval (if simple-mode-line-display-global-mode-string "  " ""))
     (:eval (if simple-mode-line-display-global-mode-string global-mode-string ""))))

(defun set-simple-mode-line-face ()
  ""
  (make-face 'mode-line-input-method-title-face)
  (make-face 'mode-line-editable-face)
  (make-face 'mode-line-read-only-face)
  (make-face 'mode-line-modified-face)
  (make-face 'mode-line-80+-face)
  (make-face 'mode-line-position-face)

  (set-face-attribute 'mode-line nil
                      :height (face-attribute 'default :height)
                      :foreground "white"
                      :background "black"
                      :inverse-video nil
                      :box (list :line-width 10 :color "black" :style nil))
  (set-face-attribute 'mode-line-inactive nil
                      :height (- (face-attribute 'default :height) 20)
                      :foreground "#888"
                      :background "black"
                      :inverse-video nil
                      :box (list :line-width 5 :color "black" :style nil))
  (set-face-attribute 'mode-line-editable-face nil
                      :inherit 'mode-line-face
                      :foreground "sky blue")
  (set-face-attribute 'mode-line-input-method-title-face nil
                      :inherit 'mode-line-face
                      :foreground "dark orange"
                      :background "#000")
  (set-face-attribute 'mode-line-read-only-face nil
                      :inherit 'mode-line-face
                      :foreground "white")
  (set-face-attribute 'mode-line-modified-face nil
                      :inherit 'mode-line-face
                      :foreground "pink")
  (set-face-attribute 'mode-line-80+-face nil
                      :inherit 'mode-line-face
                      :foreground "dark orange")
  (set-face-attribute 'mode-line-position-face nil
                      :inherit 'mode-line-face))

;;;###autoload
(defun simple-mode-line (activate-p)
  (when activate-p
    (setq-default mode-line-format nil)
    (set-simple-mode-line-face)
    (setq-default mode-line-format simple-mode-line-format)))

(provide 'simple-mode-line)

;; Local Variables:
;; no-byte-compile: t
;; End:

;;; simple-mode-line.el ends here
