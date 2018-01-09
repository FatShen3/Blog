{% extends '_layout.swig' %}
{% import '_macro/post.swig' as post_template %}

{% import '_macro/sidebar.swig' as sidebar_template %}


{% block title %}{{ page.title }} | {{ config.title }}{% endblock %}

{% block page_class %}page-post-detail{% endblock %}


{% block content %}
  <div id="posts" class="posts-expand">
    {{ post_template.render(page) }}

    <div class="post-spread">
      {% if theme.jiathis %}
        {% include '_partials/share/jiathis.swig' %}
      {% elseif theme.baidushare %}
        {% include '_partials/share/baidushare.swig' %}
      {% elseif theme.add_this_id %}
        {% include '_partials/share/add-this.swig' %}
      {% elseif theme.duoshuo_shortname and theme.duoshuo_share %}
        {% include '_partials/share/duoshuo_share.swig' %}
      {% endif %}
    </div>
  </div>
  {# git issue comment block#}
  <div id="container" class = "post-block"></div>
{% set gitmentjs = url_for(theme.vendors._internal) + '/gitment/gitment.browser.js' %}
<script src="{{gitmentjs}}"></script>
<script>
var gitment = new Gitment({
  link: 'https://github.com/FatShen3/Blog/issues',
  id: location.href, // 可选。默认为 location.href
  owner: 'FatShen3',
  repo: 'Blog',
  oauth: {
    client_id: 'ef53875e8eb831056fd4',
    client_secret: '917858401bc730b4bc3011202ad1a902262de4fc',
  },
})
gitment.render('container')
</script>
{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(true) }}
{% endblock %}

{% block script_extra %}
  {% include '_scripts/pages/post-details.swig' %}
{% endblock %}
