import './index.css'
import './markdown.css'
import $ from 'jquery'
import CodeMirror from 'codemirror'
import 'codemirror/mode/markdown/markdown'
import 'codemirror/lib/codemirror.css'
import 'codemirror/theme/neo.css'
import { marked } from 'marked'

$(function(){
  let elements = `<div class="mdeditor">
    <div class="mdeditor_toolbar"></div>
    <div class="mdeditor_body">
    <div class="mdeditor_editor">
    <textarea class="mdeditor_textarea"></textarea>
    </div>
    <div class="mdeditor_preview"></div>
    </div>
    
  </div>`
  var mdeditor = $('[data-mdeditor]')
  var textarea = $('[data-mdeditor]>textarea')
  var value = textarea.val()
  mdeditor.empty()
  mdeditor.prepend(elements)
  var custom_textarea = $('.mdeditor_textarea')
  custom_textarea.html(value)
  const editor = CodeMirror.fromTextArea(custom_textarea[0], {
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
    sanitize: true,
    smartLists: true,
    smartypants: false
  })

  markedContent(editor)
  createButton()
})

const markedContent = function(editor) {
  let value = editor.getValue()
  var markedcontent = marked.parse(value)
  let preview = $('.mdeditor_preview')
  preview.append(markedcontent)
}

const createButton = function() {
  $('.mdeditor_toolbar').append('<button class="mdeditor_bold">b</button>')
  $('.mdeditor_toolbar').append('<button class="mdeditor_italic">i</button>');
  $('.mdeditor_toolbar').append('<button class="mdeditor_code">c</button>');
  $('.mdeditor_toolbar').append('<button class="mdeditor_resize">f</button>');
}





