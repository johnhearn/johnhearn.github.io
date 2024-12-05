---
title: Notes on TDD series
layout: page
category: notes-on-tdd
---

{{ content }}

<div>
  <ul>
    {% assign posts = site.posts | sort: 'date' %}
    {% for post in posts %}
      {% if post.category == page.category %}
      <li>
        {%- assign date_format = site.minima.date_format | default: "%b %-d, %Y" -%}
        <b>
          <a href="{{ post.url | relative_url }}">
            {{ post.title | escape }}
          </a>
        </b> - <i>{{ post.date | date: date_format }}</i>
        <div>{{ post.description }}</div> 
      </li>
      {% endif %}
    {% endfor %}
  </ul>
</div>