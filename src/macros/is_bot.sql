{% macro is_bot(column) %}
    regexp_contains(lower({{ column }}, r'\[bot\]$'))
{% endmacro %}