# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    # High-level stats
    bids_active  = Bid.active.count
    bids_closed  = Bid.closed.count
    news_count   = News.published.count
    events_up    = Event.upcoming.count
    events_now   = Event.ongoing.count
    events_past  = Event.past.count
    pubs_count   = Publication.count
    vac_active   = Vacancy.active.count
    projects_cnt = Project.count
    road_assets  = RoadAsset.count
    perf_reports = PerformanceReport.count

    # Aggregations
    bids_by_category = Bid.group(:category).count.compact
    bids_cat_labels  = bids_by_category.keys.map { |k| k.presence || 'Uncategorized' }
    bids_cat_values  = bids_by_category.values

    months      = (0..5).to_a.reverse.map { |i| Date.current.beginning_of_month - i.months }
    news_labels = months.map { |d| d.strftime('%b %Y') }
    news_values = months.map { |m| News.where(published_date: m..m.end_of_month).count }

    years      = (Date.current.year - 4)..Date.current.year
    pub_labels = years.to_a
    pub_values = pub_labels.map { |y| Publication.where(year: y).count }
    
    # Extra aggregations for pie charts
    pubs_by_category = Publication.group(:category).count.compact
    pubs_cat_labels  = pubs_by_category.keys.map { |k| k.presence || 'Uncategorized' }
    pubs_cat_values  = pubs_by_category.values

    vac_by_job       = Vacancy.group(:job_type).count.compact
    vac_job_labels   = vac_by_job.keys.map { |k| k.presence || 'N/A' }
    vac_job_values   = vac_by_job.values

    proj_by_status   = Project.group(:status).count.compact
    proj_status_lbls = proj_by_status.keys.map { |k| k.presence || 'N/A' }
    proj_status_vals = proj_by_status.values

    # Basic styles for widgets and charts grid (enhanced look)
    text_node raw(<<~CSS)
      <style>
        .aa-stats{list-style:none;padding:0;margin:0 0 16px;display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:14px}
        .aa-stat{position:relative;border:1px solid rgba(var(--accent-rgb),.25);border-radius:12px;padding:14px 16px;box-shadow:0 6px 16px rgba(0,0,0,0.05);transition:transform .2s ease, box-shadow .2s ease;overflow:hidden;background:linear-gradient(135deg, rgba(var(--accent-rgb),.12), rgba(var(--accent-rgb),.06) 55%, #ffffff 100%)}
        .aa-stat:hover{transform:translateY(-3px);box-shadow:0 12px 26px rgba(0,0,0,0.08)}
        .aa-stat .label{display:block;color:#475569;font-size:12px;text-transform:uppercase;letter-spacing:.45px}
        .aa-stat .value{display:block;margin-top:6px;font-size:26px;font-weight:800;color:rgb(var(--accent-rgb))}
        .aa-stat .meta{display:block;margin-top:6px;font-size:12px}
        .aa-stat .meta a{color:rgb(var(--accent-rgb));text-decoration:none}
        .aa-stat .meta a:hover{text-decoration:underline}
        .aa-stat .icon{position:absolute;top:12px;right:12px;width:28px;height:28px;border-radius:9999px;display:grid;place-items:center;background:rgba(var(--accent-rgb),.18);color:rgb(var(--accent-rgb));font-size:14px}
        .aa-stat::after{content:"";position:absolute;inset:-40% -20% auto auto;width:240px;height:240px;background:radial-gradient(180px circle at 80% 0, rgba(var(--accent-rgb),.10), transparent 45%);opacity:.7;pointer-events:none}
        .aa-green{ --accent-rgb: 22,163,74;  --blob-color: rgba(22,163,74,.10); }
        .aa-red{   --accent-rgb: 239,68,68;  --blob-color: rgba(239,68,68,.10); }
        .aa-blue{  --accent-rgb: 37,99,235;  --blob-color: rgba(37,99,235,.10); }
        .aa-cyan{  --accent-rgb: 6,182,212;  --blob-color: rgba(6,182,212,.10); }
        .aa-orange{--accent-rgb: 245,158,11; --blob-color: rgba(245,158,11,.12); }
        .aa-purple{--accent-rgb: 168,85,247; --blob-color: rgba(168,85,247,.10); }
        .aa-indigo{--accent-rgb: 79,70,229;  --blob-color: rgba(79,70,229,.10); }
        .aa-lime{  --accent-rgb: 132,204,22; --blob-color: rgba(132,204,22,.12); }
        .aa-rose{  --accent-rgb: 244,63,94;  --blob-color: rgba(244,63,94,.12); }
        .aa-charts{display:grid;grid-template-columns:repeat(auto-fit,minmax(340px,1fr));gap:18px}
        .chart-box{background:#ffffff;border:1px solid #e5e7eb;border-radius:14px;padding:14px;box-shadow:0 6px 14px rgba(0,0,0,0.05)}
        .chart-box h3{margin:0 0 8px 0;color:#111827;font-size:14px}
        .chart-box canvas{width:100%!important;height:320px!important}
      </style>
    CSS

    # Top widgets
    panel 'At a Glance' do
      ul class: 'aa-stats' do
        li class: 'aa-stat aa-green' do
          span 'Bids (Active)', class: 'label'
          span number_with_delimiter(bids_active), class: 'value'
          span '✓', class: 'icon'
          span class: 'meta' do
            text_node link_to('View Bids', admin_bids_path)
          end
        end
        li class: 'aa-stat aa-red' do
          span 'Bids (Closed)', class: 'label'
          span number_with_delimiter(bids_closed), class: 'value'
          span '×', class: 'icon'
          span class: 'meta' do
            text_node link_to('View Bids', admin_bids_path)
          end
        end
        li class: 'aa-stat aa-blue' do
          span 'News (Published)', class: 'label'
          span number_with_delimiter(news_count), class: 'value'
          span '📰', class: 'icon'
          span class: 'meta' do
            text_node link_to('View News', admin_news_index_path)
          end
        end
        li class: 'aa-stat aa-cyan' do
          span 'Events (Upcoming)', class: 'label'
          span number_with_delimiter(events_up), class: 'value'
          span '📅', class: 'icon'
          span class: 'meta' do
            text_node link_to('View Events', admin_events_path)
          end
        end
        li class: 'aa-stat aa-orange' do
          span 'Vacancies (Active)', class: 'label'
          span number_with_delimiter(vac_active), class: 'value'
          span '💼', class: 'icon'
          span class: 'meta' do
            text_node link_to('View Vacancies', admin_vacancies_path)
          end
        end
        li class: 'aa-stat aa-purple' do
          span 'Publications', class: 'label'
          span number_with_delimiter(pubs_count), class: 'value'
          span '📚', class: 'icon'
          span class: 'meta' do
            text_node link_to('View Publications', admin_publications_path)
          end
        end
        li class: 'aa-stat aa-indigo' do
          span 'Projects', class: 'label'
          span number_with_delimiter(projects_cnt), class: 'value'
          span '🏗', class: 'icon'
          span class: 'meta' do
            text_node link_to('View Projects', admin_projects_path)
          end
        end
        li class: 'aa-stat aa-lime' do
          span 'Road Assets', class: 'label'
          span number_with_delimiter(road_assets), class: 'value'
          span '🛣', class: 'icon'
          span class: 'meta' do
            text_node link_to('View Road Assets', admin_road_assets_path)
          end
        end
        li class: 'aa-stat aa-rose' do
          span 'Performance Reports', class: 'label'
          span number_with_delimiter(perf_reports), class: 'value'
          span '📈', class: 'icon'
          span class: 'meta' do
            text_node link_to('View Reports', admin_performance_reports_path)
          end
        end
      end
    end

    # Charts Grid (Chart.js will read config from data-config)
    div class: 'aa-charts' do
      div class: 'chart-box' do
        h3 'Bids: Active vs Closed'
        text_node content_tag(:canvas, '', class: 'aa-chart', data: {
          config: {
            type: 'doughnut',
            data: { labels: ['Active','Closed'], datasets: [ { data: [bids_active, bids_closed], backgroundColor: ['#16a34a','#ef4444'] } ] },
            options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
          }.to_json
        })
      end

      div class: 'chart-box' do
        h3 'Bids by Category'
        text_node content_tag(:canvas, '', class: 'aa-chart', data: {
          config: {
            type: 'bar',
            data: { labels: bids_cat_labels, datasets: [ { label: 'Bids by Category', data: bids_cat_values, backgroundColor: '#f59e0b' } ] },
            options: { responsive: true, scales: { y: { beginAtZero: true } } }
          }.to_json
        })
      end

      div class: 'chart-box' do
        h3 'News Published (Last 6 Months)'
        text_node content_tag(:canvas, '', class: 'aa-chart', data: {
          config: {
            type: 'line',
            data: { labels: news_labels, datasets: [ { label: 'News (last 6 months)', data: news_values, borderColor: '#2563eb', backgroundColor: 'rgba(37,99,235,0.15)', fill: true, tension: 0.3 } ] },
            options: { responsive: true, scales: { y: { beginAtZero: true, ticks: { precision: 0 } } } }
          }.to_json
        })
      end

      div class: 'chart-box' do
        h3 'Events Distribution'
        text_node content_tag(:canvas, '', class: 'aa-chart', data: {
          config: {
            type: 'pie',
            data: { labels: ['Upcoming','Ongoing','Past'], datasets: [ { data: [events_up, events_now, events_past], backgroundColor: ['#06b6d4','#10b981','#a78bfa'] } ] },
            options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
          }.to_json
        })
      end

      div class: 'chart-box' do
        h3 'Publications per Year'
        text_node content_tag(:canvas, '', class: 'aa-chart', data: {
          config: {
            type: 'bar',
            data: { labels: pub_labels, datasets: [ { label: 'Publications per Year', data: pub_values, backgroundColor: '#f97316' } ] },
            options: { responsive: true, scales: { y: { beginAtZero: true, ticks: { precision: 0 } } } }
          }.to_json
        })
      end

      div class: 'chart-box' do
        h3 'Publications by Category'
        text_node content_tag(:canvas, '', class: 'aa-chart', data: {
          config: {
            type: 'pie',
            data: {
              labels: pubs_cat_labels,
              datasets: [ { data: pubs_cat_values, backgroundColor: ['#0ea5e9','#22c55e','#f59e0b','#ef4444','#8b5cf6','#06b6d4','#84cc16','#f43f5e','#a3e635','#14b8a6','#eab308'] } ]
            },
            options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
          }.to_json
        })
      end

      div class: 'chart-box' do
        h3 'Vacancies by Job Type'
        text_node content_tag(:canvas, '', class: 'aa-chart', data: {
          config: {
            type: 'pie',
            data: {
              labels: vac_job_labels,
              datasets: [ { data: vac_job_values, backgroundColor: ['#06b6d4','#10b981','#f59e0b','#ef4444','#8b5cf6','#0ea5e9'] } ]
            },
            options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
          }.to_json
        })
      end

      div class: 'chart-box' do
        h3 'Projects by Status'
        text_node content_tag(:canvas, '', class: 'aa-chart', data: {
          config: {
            type: 'pie',
            data: {
              labels: proj_status_lbls,
              datasets: [ { data: proj_status_vals, backgroundColor: ['#22c55e','#f59e0b','#3b82f6','#ef4444','#a78bfa'] } ]
            },
            options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
          }.to_json
        })
      end
    end

    # Latest content tables
    columns do
      column do
        panel 'Latest Bids' do
          table_for Bid.order(publish_date: :desc).limit(5) do
            column(:bid_number)
            column(:title) { |b| link_to b.title, admin_bid_path(b) }
            column(:status) { |b| status_tag(b.computed_status) }
            column(:publish_date)
            column(:deadline_date)
          end
          div { link_to 'View All Bids', admin_bids_path }
        end

        panel 'Latest News' do
          table_for News.order(published_date: :desc).limit(5) do
            column(:title) { |n| link_to n.title, admin_news_path(n) }
            column(:category)
            column(:published_date)
          end
          div { link_to 'View All News', admin_news_index_path }
        end
      end

      column do
        panel 'Latest Events' do
          table_for Event.order(start_date: :desc).limit(5) do
            column(:title) { |e| link_to e.title, admin_event_path(e) }
            column(:start_date)
            column(:end_date)
            column('Status') { |e| status_tag(e.status) }
          end
          div { link_to 'View All Events', admin_events_path }
        end

        panel 'Latest Publications' do
          table_for Publication.order(publish_date: :desc).limit(5) do
            column(:title) { |p| link_to p.title, admin_publication_path(p) }
            column(:category)
            column(:year)
          end
          div { link_to 'View All Publications', admin_publications_path }
        end
      end

      column do
        panel 'Latest Vacancies' do
          table_for Vacancy.order(posted_date: :desc).limit(5) do
            column(:title) { |v| link_to v.title, admin_vacancy_path(v) }
            column(:department)
            column(:deadline)
            column('State') { |v| status_tag(v.active? ? 'active' : 'expired') }
          end
          div { link_to 'View All Vacancies', admin_vacancies_path }
        end

        panel 'Latest Projects' do
          table_for Project.order(created_at: :desc).limit(5) do
            column(:title) { |p| link_to p.title, admin_project_path(p) }
            column(:created_at)
            column(:updated_at)
          end
          div { link_to 'View All Projects', admin_projects_path }
        end
      end
    end
  end
end