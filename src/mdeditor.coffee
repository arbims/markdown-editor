import './index.css'
import './markdown.css'
import './github.css'
import $ from 'jquery'
import CodeMirror from 'codemirror'
import 'codemirror/mode/markdown/markdown'
import 'codemirror/lib/codemirror.css'
import 'codemirror/theme/neo.css'
import { marked } from 'marked'
import DOMPurify from 'dompurify';

#=== editorMD ===#
$.fn.extend
  editorMD: () -> 
    elements = """<div class="mdeditor">
      <div class="mdeditor_toolbar"></div>
      <div class="mdeditor_body">
      <div class="mdeditor_editor">
      <textarea class="mdeditor_textarea"></textarea>
      </div>
      <div class="mdeditor_preview">
      </div>
      </div>
      </div>"""
    mdeditor = $('<div data-mdeditor></div>')
    this.before(mdeditor)
    value = this.val()
    mdeditor.empty()
    mdeditor.prepend(elements)
    custom_textarea = $('.mdeditor_textarea')
    custom_textarea.html(value)
    this.remove()
    editor = CodeMirror.fromTextArea(custom_textarea[0], {
      mode: 'markdown',
      tabMode: 'indent',
      theme: 'neo',
      lineWrapping: true,
      viewportMargin: Infinity,
      showMarkdownLineBreaks: true,
      cursorBlinkRate: false
    });

    marked.setOptions({
      gfm: true,
      tables: true,
      breaks: true,
      pedantic: false,
      sanitize: false,
      smartLists: true,
      smartypants: false
    })
    
    updateContent(editor)
    createButton()
    boldContent(editor)
    codeButton(editor)
    italicContent(editor)
    linkContent(editor)
    imageContent(editor)
    resizeEditor()
    markedContent(editor)
    setSection()

#=== markedContent ===#
markedContent = (editor) ->
  value = editor.getValue()
  markedcontent = DOMPurify.sanitize(marked.parse(value));
  $('.mdeditor_preview').append markedcontent

#=== resizeEditor ===#
resizeEditor = () ->
  $('.mdeditor_resize').on 'click',(e) ->
    e.preventDefault()
    if $('.mdeditor').hasClass 'fullscreen'
      $('.mdeditor').removeClass 'fullscreen'
    else
      $('.mdeditor').addClass 'fullscreen'

#=== updateContent ===#
updateContent = (editor) ->
  editor.on 'change', () ->
    value = editor.getValue()
    markedcontent = DOMPurify.sanitize(marked.parse(value))
    $('.mdeditor_preview').html(markedcontent)

#=== setSection ===# 
setSection = () ->
  selectors = []
  for i in [1..6]
    selectors.push(".cm-header-#{i}")

  matches = $(selectors.join(', ')) 
  previous = 0
  sections = []
  console.log(matches)
  $.each matches, (index, item) ->
    offset_Top = offsetTop(item)
    sections.push([previous, offset_Top])
    previous = offset_Top
  sections.push([previous, element.scrollHeight])
  return sections

offsetTop = (element, target, acc = 0) ->
  if element == target
    return acc
  console.log element
  if element != null
    return offsetTop(element.offsetParent, target, acc + element.offsetTop)

#=== boldContent ===# 
boldContent = (editor) ->
  $('.mdeditor_bold').on 'click', (e) ->
    e.preventDefault()
    editor.doc.replaceSelection('**' + editor.doc.getSelection('around') + '**')
    editor.focus()

#=== codeButton ===# 
codeButton = (editor) ->
  $('.mdeditor_code').on 'click', (e) ->
    e.preventDefault()
    editor.doc.replaceSelection('```\n' + editor.doc.getSelection() + '\n```')
    editor.focus()	

#=== italicContent ===#
italicContent = (editor) ->
  $('.mdeditor_italic').on 'click', (e) ->
    e.preventDefault()
    editor.doc.replaceSelection('*' + editor.doc.getSelection('around') + '*')
    editor.focus()

#=== imageContent ===#
imageContent = (editor) ->
  $('.mdeditor_image').on 'click', (e) ->
    e.preventDefault();
    editor.doc.replaceSelection('![' + editor.doc.getSelection('end') + ']()');
    cursor = editor.doc.getCursor();
    editor.doc.setCursor({
      line: cursor.line,
      ch: cursor.ch - 1
    })
    editor.focus()

#=== linkContent ===#  
linkContent = (editor) ->
  $('.mdeditor_link').on 'click', (e) ->
    e.preventDefault()
    editor.doc.replaceSelection('[' + editor.doc.getSelection('end') + ']()')
    cursor = editor.doc.getCursor()
    editor.doc.setCursor({
      line: cursor.line,
      ch: cursor.ch - 1
    })
    editor.focus()

#=== createButton ===#  
createButton = () ->
  $('.mdeditor_toolbar').append '<button class="mdeditor_bold">b</button>'
  $('.mdeditor_toolbar').append '<button class="mdeditor_italic">i</button>'
  $('.mdeditor_toolbar').append '<button class="mdeditor_code">c</button>'
  $('.mdeditor_toolbar').append '<button class="mdeditor_link">l</button>'
  $('.mdeditor_toolbar').append '<button class="mdeditor_image">p</button>'
  $('.mdeditor_toolbar').append '<button class="mdeditor_resize">f</button>'


