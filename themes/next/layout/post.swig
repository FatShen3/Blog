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
{% set gitmentid = page.title %}
<script src="{{gitmentjs}}"></script>
<script>
var gitment = new Gitment({
  link: 'https://github.com/FatShen3/Blog/issues',
  id: '{{gitmentid}}', // 可选。默认为 location.href, 这个会用作label，目前最长50个字符
  owner: 'FatShen3',
  repo: 'Blog',
  oauth: {
    client_id: 'df4cf8f5ace90705ef47',
    client_secret: 'f3a7368660650339761f5b7b9b2a6040a7828490',
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
