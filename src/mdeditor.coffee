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
  editorMD: (vars) -> 

    elements = """<div class="mdeditor">
      <div class="mdeditor_toolbar"></div>
      <div class="mdeditor_editor">
      <div>
        <textarea class="mdeditor_textarea"></textarea>
      </div>
      </div>
      <div class="mdeditor_preview">
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
      theme: 'neo',
      lineWrapping: true,
      viewportMargin: Infinity,
      cursorBlinkRate: 0
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
    #custom_textarea.remove()
    updateContent(editor)
    createButton()
    boldContent(editor)
    codeButton(editor)
    italicContent(editor)
    linkContent(editor)
    imageContent(editor)
    resizeEditor()
    markedContent(editor)
    mdeditor_editor_section = setSection('.mdeditor_editor')
    mdeditor_preview_section = setSection('.mdeditor_preview')
    if vars.syncScroll == true
      scrollEditor(mdeditor_editor_section, mdeditor_preview_section)
    

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

#=== ScrollEditor ===#
scrollEditor = (mdeditor_editor_section, mdeditor_preview_section) ->
  scrolling_element = null
  $('.mdeditor_editor').on 'mouseenter', ->
    scrolling_element = 'editor'
  
  $('.mdeditor_preview').on 'mouseenter', ->
    scrolling_element = 'preview'

  $('.mdeditor_editor').on 'scroll', () -> 
    if scrolling_element == 'editor'
      scrollTop = getScrolPosition($(this).scrollTop(), mdeditor_editor_section, mdeditor_preview_section)
      $('.mdeditor_preview').scrollTop(scrollTop)

  $('.mdeditor_preview').on 'scroll', () -> 
    if scrolling_element == 'preview'
      scrollTop = getScrolPosition($(this).scrollTop(), mdeditor_preview_section, mdeditor_editor_section)
      $('.mdeditor_editor').scrollTop(scrollTop)

#=== setSection ===# 
setSection = (className) ->
  element = $(className)
  selectors = []
  for i in [1..6]
    selectors.push("#{className} .cm-header-#{i}", "#{className} h#{i}")

  matches = $(selectors.join(', ')) 
  previous = 0
  sections = []
  $.each matches, (index, item) ->
    curr_item = $(item)
    offset_Top = offsetTop(curr_item, element)
    sections.push([previous, offset_Top])
    previous = offset_Top
  sections.push([previous, element.prop('scrollHeight')])
  return sections


offsetTop = (target,element, acc = 0) ->
  if element == target
    return acc  
  return offsetTop(element.parent, target, acc + element.offset().top)

#=== get Index section ===#
getIndex = (y, sections) ->
  sections.findIndex (section) ->
    return y >= section[0] && y <= section[1]

#=== getScrolPosition ===#
getScrolPosition = (y, sourceSections, targetSections) ->
  index = getIndex(y, sourceSections)
  section = sourceSections[index]
  percentage = (y - section[0]) / (section[1] - section[0])
  targetSection = targetSections[index]
  targetSection[0] + percentage * (targetSection[1] - targetSection[0])

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


