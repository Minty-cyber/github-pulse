{%  macro dev_date_filter(date_column) -%}
    {%- if target.name == 'dev' -%}
        {{date_column}} >= date('{{ var("dev_start_date") }}')
    {%- else -%}
        true
    {%- endif -%}

{% endmacro %}