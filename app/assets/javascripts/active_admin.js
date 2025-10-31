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

function loadQuill(callback) {
  if (window.Quill) { callback && callback(); return; }
  var existing = document.getElementById('quill-cdn');
  if (!document.getElementById('quill-css')) {
    var l = document.createElement('link');
    l.id = 'quill-css';
    l.rel = 'stylesheet';
    l.href = 'https://cdn.jsdelivr.net/npm/quill@1.3.7/dist/quill.snow.css';
    document.head.appendChild(l);
  }
  if (existing) {
    existing.addEventListener('load', function(){ callback && callback(); }, { once: true });
    return;
  }
  var s = document.createElement('script');
  s.id = 'quill-cdn';
  s.src = 'https://cdn.jsdelivr.net/npm/quill@1.3.7/dist/quill.min.js';
  s.async = true;
  s.onload = function(){ callback && callback(); };
  document.head.appendChild(s);
}

function initQuillEditors() {
  if (!window.Quill) return;
  var textareas = document.querySelectorAll('textarea.aa-richtext');
  textareas.forEach(function(ta) {
    if (ta._aaQuillInited) return;
    ta._aaQuillInited = true;
    ta.style.display = 'none';
    var wrapper = document.createElement('div');
    var editor = document.createElement('div');
    editor.className = 'aa-quill-editor';
    editor.innerHTML = ta.value || '';
    wrapper.appendChild(editor);
    ta.parentNode.insertBefore(wrapper, ta.nextSibling);
    var q = new Quill(editor, { theme: 'snow' });
    // Sync on form submit
    var form = ta.closest('form');
    if (form && !form._aaQuillHooked) {
      form._aaQuillHooked = true;
      form.addEventListener('submit', function(){
        document.querySelectorAll('textarea.aa-richtext').forEach(function(t){
          if (t._aaQuillInited && t.nextSibling && t.nextSibling.querySelector('.aa-quill-editor')) {
            var ed = t.nextSibling.querySelector('.aa-quill-editor');
            var ql = ed.__quill || (ed && ed.parentNode && ed.parentNode.__quill);
            if (ql) { t.value = ql.root.innerHTML; }
          }
        });
      });
    }
    // Keep reference
    editor.__quill = q;
  });
}

function loadCKEditor(callback) {
  if (window.ClassicEditor) { callback && callback(); return; }
  var existing = document.getElementById('ckeditor5-cdn');
  if (existing) {
    existing.addEventListener('load', function(){ callback && callback(); }, { once: true });
    return;
  }
  var s = document.createElement('script');
  s.id = 'ckeditor5-cdn';
  // Super-build includes Base64UploadAdapter and MediaEmbed out of the box
  s.src = 'https://cdn.ckeditor.com/ckeditor5/41.3.1/super-build/ckeditor.js';
  s.async = true;
  s.onload = function(){ callback && callback(); };
  document.head.appendChild(s);
}

function initCKEditors() {
  if (!window.ClassicEditor) return;
  var textareas = document.querySelectorAll('textarea.aa-richtext');
  textareas.forEach(function(ta) {
    if (ta._aaCkInited) return;
    ta._aaCkInited = true;
    var holder = document.createElement('div');
    holder.className = 'aa-ckeditor-holder';
    ta.style.display = 'none';
    ta.parentNode.insertBefore(holder, ta.nextSibling);
    window.ClassicEditor
      .create(holder, {
        initialData: ta.value || '',
        toolbar: {
          items: [ 'heading','|','bold','italic','underline','link','bulletedList','numberedList','blockQuote','insertTable','mediaEmbed','imageUpload','undo','redo' ]
        },
        removePlugins: [ 'CKBox','CKFinder','EasyImage','RealTimeCollaborativeComments','RealTimeCollaborativeTrackChanges','RealTimeCollaborativeRevisionHistory','PresenceList','Comments','TrackChanges','TrackChangesData','RevisionHistory','Pagination','WProofreader','MathType','SlashCommand','Template','DocumentOutline','FormatPainter','TableOfContents','PasteFromOfficeEnhanced' ]
      })
      .then(function(editor){
        ta._editor = editor;
        // Sync back to textarea on submit
        var form = ta.closest('form');
        if (form && !form._aaCkHooked) {
          form._aaCkHooked = true;
          form.addEventListener('submit', function(){
            document.querySelectorAll('textarea.aa-richtext').forEach(function(t){
              if (t._editor) { t.value = t._editor.getData(); }
            });
          });
        }
      })
      .catch(function(e){ console && console.warn('CKEditor init failed', e); });
  });
}

function bootRichText() {
  loadCKEditor(function(){ initCKEditors(); });
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

function observeForRichTextEditors() {
  try {
    var observer = new MutationObserver(function(mutations){
      var needsInit = false;
      mutations.forEach(function(m){
        if (m.addedNodes && m.addedNodes.length) {
          m.addedNodes.forEach(function(n){
            if (n.nodeType === 1) {
              if (n.matches && n.matches('textarea.aa-richtext')) needsInit = true;
              if (!needsInit && n.querySelector && n.querySelector('textarea.aa-richtext')) needsInit = true;
            }
          });
        }
      });
      if (needsInit) { bootRichText(); }
    });
    observer.observe(document.documentElement || document.body, { childList: true, subtree: true });
  } catch (e) { /* no-op */ }
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
  // Initialize rich text editors (CKEditor)
  bootRichText();
  observeForRichTextEditors();
});
// Also re-init charts when using Turbolinks/Turbo navigations
if (document.addEventListener) {
  document.addEventListener('turbolinks:load', function(){ bootCharts(); bootRichText(); observeForRichTextEditors(); });
  document.addEventListener('turbo:load', function(){ bootCharts(); bootRichText(); observeForRichTextEditors(); });
}