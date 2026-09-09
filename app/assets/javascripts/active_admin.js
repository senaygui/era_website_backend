//= require jquery
//= require rails-ujs
//= require active_admin/base
//= require activeadmin_addons/all
//= require activestorage



// Chart.js lazy loader and initializer for ActiveAdmin dashboard
function loadChartJs(callback) {
  if (window.Chart) { callback && callback(); return; }
  var existing = document.getElementById('chartjs-cdn');
  if (existing) {
    // If tag exists but Chart may not be ready yet, wait for load
    if (window.Chart) { callback && callback(); return; }
    existing.addEventListener('load', function(){ callback && callback(); }, { once: true });
    return;
  }
  var s = document.createElement('script');
  s.id = 'chartjs-cdn';
  s.src = 'https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js';
  s.async = true;
  s.onload = function() { callback && callback(); };
  document.head.appendChild(s);
}

function initAACharts() {
  if (!window.Chart) return;
  var els = document.querySelectorAll('canvas.aa-chart');
  els.forEach(function(el) {
    try {
      var raw = el.getAttribute('data-config');
      var cfg = raw ? JSON.parse(raw) : null;
      if (!cfg) return;
      // Apply sensible defaults
      cfg.options = cfg.options || {};
      cfg.options.maintainAspectRatio = false;
      cfg.options.plugins = cfg.options.plugins || {};
      cfg.options.plugins.legend = cfg.options.plugins.legend || { position: 'bottom' };
      // Add datalabels defaults for pie/doughnut
      var t = (cfg.type || '').toLowerCase();
      if ((t === 'pie' || t === 'doughnut')) {
        cfg.options.plugins.datalabels = cfg.options.plugins.datalabels || {
          color: '#ffffff',
          font: { weight: 'bold' },
          formatter: function(value, context) {
            try {
              var data = context.chart.data.datasets[0].data || [];
              var total = data.reduce(function(a,b){ return a + (Number(b) || 0); }, 0);
              if (!total) return '0%';
              var pct = Math.round((Number(value) || 0) * 100 / total);
              return pct + '%';
            } catch(e) { return ''; }
          }
        };
      }
      var ctx = el.getContext('2d');
      // Store instance to avoid duplicates on repeated init
      if (el._aaChart) { el._aaChart.destroy(); }
      el._aaChart = new Chart(ctx, cfg);
    } catch (e) {
      // eslint-disable-next-line no-console
      console && console.warn('Chart init failed:', e);
    }
  });
}

function setupChartDefaults() {
  if (!window.Chart) return;
  // Theme defaults
  Chart.defaults.font.family = 'Inter, ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial';
  Chart.defaults.color = '#111827';
  Chart.defaults.borderColor = 'rgba(17,24,39,0.08)';
  Chart.defaults.plugins.legend.labels.usePointStyle = true;
  Chart.defaults.plugins.tooltip.backgroundColor = 'rgba(17,24,39,0.92)';
  Chart.defaults.plugins.tooltip.titleColor = '#ffffff';
  Chart.defaults.plugins.tooltip.bodyColor = '#e5e7eb';
  Chart.defaults.plugins.tooltip.padding = 12;
}

function loadChartDatalabels(callback) {
  function finish() {
    try {
      if (window.Chart && window.ChartDataLabels && !window.Chart._aaDatalabelsRegistered) {
        window.Chart.register(window.ChartDataLabels);
        window.Chart._aaDatalabelsRegistered = true;
      }
    } catch (e) {}
    callback && callback();
  }
  if (window.Chart && window.ChartDataLabels) { finish(); return; }
  if (!window.Chart) { loadChartJs(function(){ loadChartDatalabels(callback); }); return; }
  var existing = document.getElementById('chartjs-datalabels-cdn');
  if (existing) {
    if (window.ChartDataLabels) { finish(); return; }
    existing.addEventListener('load', finish, { once: true });
    return;
  }
  var s = document.createElement('script');
  s.id = 'chartjs-datalabels-cdn';
  s.src = 'https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.2.0';
  s.async = true;
  s.onload = finish;
  document.head.appendChild(s);
}

function initNativeRichTextEditors() {
  var textareas = document.querySelectorAll('textarea:not(.aa-plain-text)');
  textareas.forEach(function(ta) {
    if (ta._aaNativeEditorInited) return;
    ta._aaNativeEditorInited = true;

    var wrapper = document.createElement('div');
    wrapper.className = 'aa-native-editor';
    var toolbar = document.createElement('div');
    toolbar.className = 'aa-native-editor__toolbar';
    toolbar.setAttribute('role', 'toolbar');
    toolbar.setAttribute('aria-label', 'Text formatting');
    var editor = document.createElement('div');
    editor.className = 'aa-native-editor__content';
    editor.contentEditable = 'true';
    editor.setAttribute('role', 'textbox');
    editor.setAttribute('aria-multiline', 'true');
    editor.setAttribute('data-placeholder', ta.getAttribute('placeholder') || 'Enter content…');

    if (/<[a-z][\s\S]*>/i.test(ta.value || '')) editor.innerHTML = ta.value;
    else editor.textContent = ta.value || '';

    var savedRange = null;
    function syncValue() { ta.value = editor.innerHTML; }
    function saveSelection() {
      var selection = window.getSelection();
      if (selection && selection.rangeCount && editor.contains(selection.anchorNode)) {
        savedRange = selection.getRangeAt(0).cloneRange();
      }
    }
    function restoreSelection() {
      if (!savedRange) return;
      var selection = window.getSelection();
      selection.removeAllRanges();
      selection.addRange(savedRange);
    }
    function addSeparator() {
      var separator = document.createElement('span');
      separator.className = 'aa-native-editor__separator';
      toolbar.appendChild(separator);
    }
    function addButton(label, title, command, value) {
      var button = document.createElement('button');
      button.type = 'button';
      button.className = 'aa-native-editor__button';
      button.innerHTML = label;
      button.title = title;
      button.setAttribute('aria-label', title);
      button.addEventListener('mousedown', function(event) {
        event.preventDefault();
        editor.focus();
        document.execCommand(command, false, value || null);
        syncValue();
      });
      toolbar.appendChild(button);
      return button;
    }

    var heading = document.createElement('select');
    heading.className = 'aa-native-editor__select';
    heading.title = 'Text style';
    [['p', 'Paragraph'], ['h2', 'Heading'], ['h3', 'Subheading'], ['pre', 'Code block']].forEach(function(item) {
      var option = document.createElement('option');
      option.value = item[0];
      option.textContent = item[1];
      heading.appendChild(option);
    });
    heading.addEventListener('change', function() {
      editor.focus();
      document.execCommand('formatBlock', false, heading.value);
      syncValue();
      heading.value = 'p';
    });
    toolbar.appendChild(heading);

    var commands = [
      ['bold', '<strong>B</strong>', 'Bold'],
      ['italic', '<em>I</em>', 'Italic'],
      ['underline', '<u>U</u>', 'Underline'],
      ['strikeThrough', '<s>S</s>', 'Strikethrough']
    ];
    commands.forEach(function(item) { addButton(item[1], item[2], item[0]); });
    addSeparator();
    addButton('• List', 'Bulleted list', 'insertUnorderedList');
    addButton('1. List', 'Numbered list', 'insertOrderedList');
    addButton('❝', 'Block quote', 'formatBlock', 'blockquote');
    addButton('―', 'Horizontal line', 'insertHorizontalRule');
    addSeparator();
    addButton('↶', 'Undo', 'undo');
    addButton('↷', 'Redo', 'redo');
    addButton('⇤', 'Outdent', 'outdent');
    addButton('⇥', 'Indent', 'indent');
    addButton('≡', 'Align left', 'justifyLeft');
    addButton('≣', 'Align center', 'justifyCenter');
    addButton('≡', 'Align right', 'justifyRight');
    addSeparator();

    var linkButton = document.createElement('button');
    linkButton.type = 'button';
    linkButton.className = 'aa-native-editor__button';
    linkButton.textContent = 'Link';
    linkButton.title = 'Insert link';
    linkButton.addEventListener('mousedown', function(event) {
      event.preventDefault();
      var url = window.prompt('Enter the link URL');
      if (!url) return;
      editor.focus();
      document.execCommand('createLink', false, url);
      syncValue();
    });
    toolbar.appendChild(linkButton);
    addButton('Unlink', 'Remove link', 'unlink');
    addButton('Clear', 'Clear formatting', 'removeFormat');

    var uploadInput = document.createElement('input');
    uploadInput.type = 'file';
    uploadInput.multiple = true;
    uploadInput.accept = 'image/*,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.zip';
    uploadInput.className = 'aa-native-editor__file-input';
    var uploadButton = document.createElement('button');
    uploadButton.type = 'button';
    uploadButton.className = 'aa-native-editor__button aa-native-editor__upload';
    uploadButton.textContent = 'Upload file';
    uploadButton.title = 'Upload and insert images or documents';
    uploadButton.addEventListener('mousedown', function() { saveSelection(); });
    uploadButton.addEventListener('click', function() { uploadInput.click(); });
    toolbar.appendChild(uploadButton);

    var status = document.createElement('span');
    status.className = 'aa-native-editor__status';
    toolbar.appendChild(status);

    uploadInput.addEventListener('change', function() {
      var files = Array.prototype.slice.call(uploadInput.files || []);
      if (!files.length) return;
      if (!(window.ActiveStorage && window.ActiveStorage.DirectUpload)) {
        status.textContent = 'Upload service unavailable';
        status.classList.add('is-error');
        return;
      }

      status.classList.remove('is-error');
      status.textContent = 'Uploading…';
      var remaining = files.length;
      files.forEach(function(file) {
        var upload = new window.ActiveStorage.DirectUpload(file, '/rails/active_storage/direct_uploads');
        upload.create(function(error, blob) {
          if (error) {
            status.textContent = 'Upload failed: ' + error;
            status.classList.add('is-error');
            return;
          }
          var csrf = document.querySelector('meta[name="csrf-token"]');
          fetch('/admin/editor_uploads', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'X-CSRF-Token': csrf ? csrf.content : ''
            },
            body: JSON.stringify({ signed_id: blob.signed_id })
          }).then(function(response) {
            return response.json().then(function(data) {
              if (!response.ok) throw new Error(data.error || 'Could not save upload');
              return data;
            });
          }).then(function(data) {
            var safeName = String(data.filename || file.name)
              .replace(/&/g, '&amp;').replace(/</g, '&lt;')
              .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
            editor.focus();
            restoreSelection();
            if ((data.content_type || file.type || '').indexOf('image/') === 0) {
              document.execCommand('insertHTML', false, '<img src="' + data.url + '" alt="' + safeName + '">');
            } else {
              document.execCommand('insertHTML', false, '<a href="' + data.url + '" target="_blank" rel="noopener">' + safeName + '</a>');
            }
            syncValue();
            remaining -= 1;
            if (remaining === 0) {
              status.textContent = files.length === 1 ? 'File uploaded' : files.length + ' files uploaded';
              window.setTimeout(function() { status.textContent = ''; }, 3000);
            }
          }).catch(function(uploadError) {
            status.textContent = 'Upload failed: ' + uploadError.message;
            status.classList.add('is-error');
          });
        });
      });
      uploadInput.value = '';
    });

    editor.addEventListener('input', syncValue);
    editor.addEventListener('keyup', saveSelection);
    editor.addEventListener('mouseup', saveSelection);
    wrapper.appendChild(toolbar);
    wrapper.appendChild(editor);
    wrapper.appendChild(uploadInput);
    ta.parentNode.insertBefore(wrapper, ta.nextSibling);
    ta.style.display = 'none';
  });
}

// Boot charts after helpers are available
function bootCharts() {
  if (window.Chart) {
    setupChartDefaults();
    if (window.ChartDataLabels) {
      if (!window.Chart._aaDatalabelsRegistered) {
        // Ensure plugin is actually registered
        try { window.Chart.register(window.ChartDataLabels); } catch(e) {}
        window.Chart._aaDatalabelsRegistered = true;
      }
      initAACharts();
    } else {
      loadChartDatalabels(function(){ setupChartDefaults(); initAACharts(); });
    }
  } else {
    loadChartJs(function(){ loadChartDatalabels(function(){ setupChartDefaults(); initAACharts(); }); });
  }
}

// DOM behaviors and chart bootstrapping
$(document).ready(function () {
  // Ensure method links work with Turbo by mapping data-method -> data-turbo-method
  try {
    function mapMethodLinks() {
      $('a[data-method]').each(function(){
        var $el = $(this);
        var m = $el.attr('data-method');
        if (m) { $el.attr('data-turbo-method', m); }
        var c = $el.attr('data-confirm');
        if (c) { $el.attr('data-turbo-confirm', c); }
      });
    }
    mapMethodLinks();
    document.addEventListener('turbo:load', mapMethodLinks);
    document.addEventListener('turbolinks:load', mapMethodLinks);
  } catch (e) {}

  // Polyfill: if neither rails-ujs nor Turbo handles data-method, submit a form with _method
  try {
    var hasRailsUJS = !!(window.Rails && window.Rails.ajax);
    var hasTurbo = !!window.Turbo;
    if (!hasRailsUJS && !hasTurbo) {
      $(document).on('click', 'a[data-method]', function (e) {
        var $link = $(this);
        var method = ($link.attr('data-method') || '').toUpperCase();
        if (!method) return;
        // GET links should use normal browser navigation. HTML forms only
        // support GET/POST and Rack does not treat _method=GET as an override.
        if (method === 'GET') return;
        var confirmMsg = $link.attr('data-confirm');
        if (confirmMsg && !window.confirm(confirmMsg)) {
          e.preventDefault();
          return false;
        }
        e.preventDefault();
        var action = $link.attr('href');
        if (!action) return false;
        var form = document.createElement('form');
        form.method = 'POST';
        form.action = action;
        // CSRF token
        var token = document.querySelector('meta[name="csrf-token"]');
        if (token && token.content) {
          var input = document.createElement('input');
          input.type = 'hidden';
          input.name = 'authenticity_token';
          input.value = token.content;
          form.appendChild(input);
        }
        // Method override
        var m = document.createElement('input');
        m.type = 'hidden';
        m.name = '_method';
        m.value = method;
        form.appendChild(m);
        document.body.appendChild(form);
        form.submit();
        return false;
      });
    }
  } catch (e) {}
  // Add header banner
  if ($('#header').length) {
    $('#header').before("<div class='outline'><div class='banner-logo'></div> <h1 class='banner-title'></h1></div>");
  }

  function toggleFields() {
    var role = $('#admin_user_role').val();
    if (role === 'dean') {
      $('.faculty-select').closest('.input').show();
    } else {
      $('.faculty-select').closest('.input').hide();
    }
    if (role === 'instructor') {
      $('.position-select').closest('.input').show();
      $('.educational-level-select').closest('.input').show();
      $('.employee-type-select').closest('.input').show();
    } else {
      $('.position-select').closest('.input').hide();
      $('.educational-level-select').closest('.input').hide();
      $('.employee-type-select').closest('.input').hide();
    }
  }

  // Initial check
  toggleFields();

  // Check on role change
  $('#admin_user_role').change(function() {
    toggleFields();
  });

  $("#student_photo").change(function (data) {
    var imageFile = data.target.files[0];
    var reader = new FileReader();
    reader.readAsDataURL(imageFile);
    reader.onload = function (evt) {
      $('#imagePreview').attr('src', evt.target.result);
      $('#imagePreview').hide();
      $('#imagePreview').fadeIn(650);
    }
  });

  $("#payment_method_bank_logo").change(function (data) {
    var imageFile = data.target.files[0];
    var reader = new FileReader();
    reader.readAsDataURL(imageFile);
    reader.onload = function (evt) {
      $('#imagePreview').attr('src', evt.target.result);
      $('#imagePreview').hide();
      $('#imagePreview').fadeIn(650);
    }
  });

  if ($('#purchase_type_of_supplier').val() == "") {
    $('.grp1').hide();
    $('.grp2').hide();
  } else if ($('#purchase_type_of_supplier').val() == 'International Supplier') {
    $('.grp1').show();
    $('.grp2').hide();
  } else if ($('#purchase_type_of_supplier').val() == 'Local Vender') {
    $('.grp1').hide();
    $('.grp2').show();
  }

  $('#purchase_type_of_supplier').change(function () {
    var value;
    value = $(this).val();
    if (value === 'International Supplier') {
      $('.grp1').show();
      $('.grp2').hide();
    } else if (value === 'Local Vender') {
      $('.grp1').hide();
      $('.grp2').show();
    }
  });

  $('.link').on('click', function (e) {
    e.preventDefault();
    let $container = $(this).closest('.widgetContainer').first();
    if ($container.css('overflow') == "hidden") {
      $container.css({
        height: 'auto',
        overflow: 'visible'
      });
    } else {
      $container.css({
        height: '120px',
        overflow: 'hidden'
      });
    }
  });

  // Initialize charts after DOM ready
  bootCharts();
});
// Also re-init charts when using Turbolinks/Turbo navigations
if (document.addEventListener) {
  document.addEventListener('turbolinks:load', bootCharts);
  document.addEventListener('turbo:load', bootCharts);
}
