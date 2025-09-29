//= require jquery
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