import { Editor } from "https://esm.sh/@tiptap/core@3"
import StarterKit from "https://esm.sh/@tiptap/starter-kit@3"
import Image from "https://esm.sh/@tiptap/extension-image@3"

const instances = new WeakMap()

function button(label, title, action, active) {
  const element = document.createElement("button")
  element.type = "button"
  element.className = "aa-tiptap__button"
  element.innerHTML = label
  element.title = title
  element.setAttribute("aria-label", title)
  element.addEventListener("click", action)
  element.updateActiveState = () => {
    element.classList.toggle("is-active", Boolean(active && active()))
  }
  return element
}

function initializeEditor(textarea) {
  if (instances.has(textarea) || textarea.disabled || textarea.readOnly) return

  const wrapper = document.createElement("div")
  wrapper.className = "aa-tiptap"

  const toolbar = document.createElement("div")
  toolbar.className = "aa-tiptap__toolbar"
  toolbar.setAttribute("role", "toolbar")
  toolbar.setAttribute("aria-label", "Rich text formatting")

  const content = document.createElement("div")
  content.className = "aa-tiptap__content"
  wrapper.append(toolbar, content)
  textarea.insertAdjacentElement("afterend", wrapper)
  textarea.hidden = true

  const editor = new Editor({
    element: content,
    extensions: [
      StarterKit.configure({
        heading: { levels: [2, 3] },
        link: { openOnClick: false },
      }),
      Image,
    ],
    content: textarea.value || "",
    editorProps: {
      attributes: {
        class: "aa-tiptap__editable",
        "aria-label": textarea.getAttribute("aria-label") || "Rich text content",
      },
    },
    onUpdate: ({ editor: currentEditor }) => {
      textarea.value = currentEditor.isEmpty ? "" : currentEditor.getHTML()
    },
  })

  const controls = []
  const addButton = (label, title, command, active) => {
    const control = button(label, title, command, active)
    controls.push(control)
    toolbar.appendChild(control)
  }
  const separator = () => {
    const element = document.createElement("span")
    element.className = "aa-tiptap__separator"
    toolbar.appendChild(element)
  }

  const styleMenu = document.createElement("div")
  styleMenu.className = "aa-tiptap__style-menu"
  const styleButton = button("Paragraph <span aria-hidden=\"true\">▾</span>", "Text style", () => {
    const expanded = styleButton.getAttribute("aria-expanded") === "true"
    styleButton.setAttribute("aria-expanded", String(!expanded))
    styleMenu.classList.toggle("is-open", !expanded)
  })
  styleButton.classList.add("aa-tiptap__style-button")
  styleButton.setAttribute("aria-haspopup", "menu")
  styleButton.setAttribute("aria-expanded", "false")

  const styleOptions = document.createElement("div")
  styleOptions.className = "aa-tiptap__style-options"
  styleOptions.setAttribute("role", "menu")
  ;[
    ["Paragraph", () => editor.chain().focus().setParagraph().run()],
    ["Heading", () => editor.chain().focus().setHeading({ level: 2 }).run()],
    ["Subheading", () => editor.chain().focus().setHeading({ level: 3 }).run()],
    ["Code block", () => editor.chain().focus().toggleCodeBlock().run()],
  ].forEach(([label, command]) => {
    const option = button(label, label, () => {
      command()
      styleMenu.classList.remove("is-open")
      styleButton.setAttribute("aria-expanded", "false")
    })
    option.classList.add("aa-tiptap__style-option")
    option.setAttribute("role", "menuitem")
    styleOptions.appendChild(option)
  })
  styleMenu.append(styleButton, styleOptions)
  toolbar.appendChild(styleMenu)

  addButton("<strong>B</strong>", "Bold", () => editor.chain().focus().toggleBold().run(), () => editor.isActive("bold"))
  addButton("<em>I</em>", "Italic", () => editor.chain().focus().toggleItalic().run(), () => editor.isActive("italic"))
  addButton("<u>U</u>", "Underline", () => editor.chain().focus().toggleUnderline().run(), () => editor.isActive("underline"))
  addButton("<s>S</s>", "Strikethrough", () => editor.chain().focus().toggleStrike().run(), () => editor.isActive("strike"))
  separator()
  addButton("• List", "Bulleted list", () => editor.chain().focus().toggleBulletList().run(), () => editor.isActive("bulletList"))
  addButton("1. List", "Numbered list", () => editor.chain().focus().toggleOrderedList().run(), () => editor.isActive("orderedList"))
  addButton("❝", "Block quote", () => editor.chain().focus().toggleBlockquote().run(), () => editor.isActive("blockquote"))
  addButton("―", "Horizontal line", () => editor.chain().focus().setHorizontalRule().run())
  separator()
  addButton("↶", "Undo", () => editor.chain().focus().undo().run())
  addButton("↷", "Redo", () => editor.chain().focus().redo().run())

  const link = button("Link", "Add or edit link", () => {
    const previous = editor.getAttributes("link").href || ""
    const href = window.prompt("Enter the link URL", previous)
    if (href === null) return
    if (href.trim() === "") editor.chain().focus().extendMarkRange("link").unsetLink().run()
    else editor.chain().focus().extendMarkRange("link").setLink({ href: href.trim() }).run()
  }, () => editor.isActive("link"))
  controls.push(link)
  toolbar.appendChild(link)
  addButton("Unlink", "Remove link", () => editor.chain().focus().unsetLink().run())
  addButton("Clear", "Clear formatting", () => editor.chain().focus().unsetAllMarks().clearNodes().run())

  const fileInput = document.createElement("input")
  fileInput.type = "file"
  fileInput.multiple = true
  fileInput.accept = "image/*,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.zip"
  fileInput.className = "aa-tiptap__file-input"

  const status = document.createElement("span")
  status.className = "aa-tiptap__status"
  const upload = button("Upload file", "Upload and insert images or documents", () => fileInput.click())
  upload.classList.add("aa-tiptap__upload")
  toolbar.append(status, upload, fileInput)

  fileInput.addEventListener("change", async () => {
    const files = Array.from(fileInput.files || [])
    if (!files.length) return
    if (!(window.ActiveStorage && window.ActiveStorage.DirectUpload)) {
      status.textContent = "Upload service unavailable"
      status.classList.add("is-error")
      return
    }

    status.classList.remove("is-error")
    status.textContent = "Uploading…"
    const uploadUrl = textarea.dataset.editorUploadUrl

    try {
      for (const file of files) {
        const blob = await new Promise((resolve, reject) => {
          new window.ActiveStorage.DirectUpload(file, "/rails/active_storage/direct_uploads")
            .create((error, result) => error ? reject(error) : resolve(result))
        })
        const csrf = document.querySelector('meta[name="csrf-token"]')
        const response = await fetch(uploadUrl, {
          method: "POST",
          credentials: "same-origin",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
            "X-CSRF-Token": csrf ? csrf.content : "",
          },
          body: JSON.stringify({ signed_id: blob.signed_id }),
        })
        const data = await response.json()
        if (!response.ok) throw new Error(data.error || "Could not save upload")

        if ((data.content_type || file.type || "").startsWith("image/")) {
          editor.chain().focus().setImage({ src: data.url, alt: data.filename || file.name }).run()
        } else {
          editor.chain().focus().insertContent({
            type: "text",
            text: data.filename || file.name,
            marks: [{ type: "link", attrs: { href: data.url, target: "_blank", rel: "noopener noreferrer" } }],
          }).run()
        }
      }
      status.textContent = files.length === 1 ? "File uploaded" : `${files.length} files uploaded`
      window.setTimeout(() => { status.textContent = "" }, 3000)
    } catch (error) {
      status.textContent = `Upload failed: ${error.message || error}`
      status.classList.add("is-error")
    } finally {
      fileInput.value = ""
    }
  })

  const updateControls = () => {
    controls.forEach(control => control.updateActiveState())
    const label = editor.isActive("heading", { level: 2 }) ? "Heading" :
      editor.isActive("heading", { level: 3 }) ? "Subheading" :
        editor.isActive("codeBlock") ? "Code block" : "Paragraph"
    styleButton.innerHTML = `${label} <span aria-hidden="true">▾</span>`
  }
  editor.on("selectionUpdate", updateControls)
  editor.on("transaction", updateControls)
  textarea.closest("form")?.addEventListener("submit", () => {
    textarea.value = editor.isEmpty ? "" : editor.getHTML()
  })
  instances.set(textarea, editor)
  updateControls()

  document.addEventListener("click", event => {
    if (styleMenu.contains(event.target)) return
    styleMenu.classList.remove("is-open")
    styleButton.setAttribute("aria-expanded", "false")
  })
}

function initializeEditors(root = document) {
  if (root.matches?.("textarea.aa-tiptap-input")) initializeEditor(root)
  root.querySelectorAll?.("textarea.aa-tiptap-input").forEach(initializeEditor)
}

initializeEditors()
document.addEventListener("turbo:load", () => initializeEditors())
document.addEventListener("turbolinks:load", () => initializeEditors())

new MutationObserver(mutations => {
  mutations.forEach(mutation => mutation.addedNodes.forEach(node => {
    if (node.nodeType === Node.ELEMENT_NODE) initializeEditors(node)
  }))
}).observe(document.documentElement, { childList: true, subtree: true })
