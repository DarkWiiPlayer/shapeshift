
<!doctype html>
<html lang="en">
  <head>
    <title>Code coverage report for shapeshift_spec.moon</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../style/reset.css">
    <link rel="stylesheet" href="../style/style.css">
  </head>
  <body>
   <div id="page-container">
      <header>
        <nav>
          
<ul class="inline-list">
    <li>
      <a href="../index.html">All Files</a> /
    </li>
    <li>
      <a href="./index.html">spec</a> /
    </li>

  <li>shapeshift_spec.moon</li>
</ul>

        </nav>
      </header>

      <main>
        <header class="hit-miss-statistics">
          
<ul class="inline-list">
  <li>
    <span class="strong">89.19%</span>
    <span class="quiet">Rate</span>
  </li>
  <li>
    <span class="strong">33</span>
    <span class="quiet">Hits</span>
  </li>
  <li>
    <span class="strong">4</span>
    <span class="quiet">Missed</span>
  </li>
</ul>

<div class="hit-percentage-status hit-percentage-status-high"></div>

        </header>
        <section id="content">
          
  <section class="file-coverage">

    <ul class="line-numbers undecorated">
        <li>1</li>
        <li>2</li>
        <li>3</li>
        <li>4</li>
        <li>5</li>
        <li>6</li>
        <li>7</li>
        <li>8</li>
        <li>9</li>
        <li>10</li>
        <li>11</li>
        <li>12</li>
        <li>13</li>
        <li>14</li>
        <li>15</li>
        <li>16</li>
        <li>17</li>
        <li>18</li>
        <li>19</li>
        <li>20</li>
        <li>21</li>
        <li>22</li>
        <li>23</li>
        <li>24</li>
        <li>25</li>
        <li>26</li>
        <li>27</li>
        <li>28</li>
        <li>29</li>
        <li>30</li>
        <li>31</li>
        <li>32</li>
        <li>33</li>
        <li>34</li>
        <li>35</li>
        <li>36</li>
        <li>37</li>
        <li>38</li>
        <li>39</li>
        <li>40</li>
    </ul>

    <ul class="line-coverages undecorated">
        <li class="line-hit">1x</li>
        <li class="line-hit">1x</li>
        <li class="line-empty">
</li>
        <li class="line-hit">2x</li>
        <li class="line-hit">2x</li>
        <li class="line-hit">1x</li>
        <li class="line-hit">1x</li>
        <li class="line-hit">1x</li>
        <li class="line-hit">1x</li>
        <li class="line-hit">1x</li>
        <li class="line-hit">1x</li>
        <li class="line-hit">1x</li>
        <li class="line-hit">2x</li>
        <li class="line-hit">2x</li>
        <li class="line-hit">10x</li>
        <li class="line-hit">5x</li>
        <li class="line-hit">5x</li>
        <li class="line-hit">5x</li>
        <li class="line-hit">6x</li>
        <li class="line-hit">2x</li>
        <li class="line-hit">2x</li>
        <li class="line-hit">1x</li>
        <li class="line-miss">
</li>
        <li class="line-hit">1x</li>
        <li class="line-hit">2x</li>
        <li class="line-hit">2x</li>
        <li class="line-empty">
</li>
        <li class="line-miss">
</li>
        <li class="line-hit">1x</li>
        <li class="line-hit">2x</li>
        <li class="line-empty">
</li>
        <li class="line-hit">1x</li>
        <li class="line-hit">1x</li>
        <li class="line-miss">
</li>
        <li class="line-hit">1x</li>
        <li class="line-hit">2x</li>
        <li class="line-hit">2x</li>
        <li class="line-hit">1x</li>
        <li class="line-hit">1x</li>
        <li class="line-miss">
</li>
    </ul>

    <ul class="code undecorated">
        <li class="line-hit">package.path = &quot;?&#47;init.lua;?.lua;&quot; .. package.path</li>
        <li class="line-hit">shapeshift = require &#39;shapeshift&#39;</li>
        <li class="line-empty">
</li>
        <li class="line-hit">describe &#39;shapeshift&#39;, -&gt;</li>
        <li class="line-hit">	describe &#39;is&#39;, -&gt;</li>
        <li class="line-hit">		it &#39;returns helper functions for type-checking&#39;, -&gt;</li>
        <li class="line-hit">			status, message = shapeshift.is.string(&quot;foobar&quot;)</li>
        <li class="line-hit">			assert.truthy status</li>
        <li class="line-hit">			status, message = shapeshift.is.string(20)</li>
        <li class="line-hit">			assert.falsy status</li>
        <li class="line-hit">			assert.is.string message</li>
        <li class="line-hit">	describe &#39;table&#39;, -&gt;</li>
        <li class="line-hit">		before_each -&gt;</li>
        <li class="line-hit">			export person = shapeshift.table {</li>
        <li class="line-hit">				name: shapeshift.is.string</li>
        <li class="line-hit">				age: shapeshift.is.number</li>
        <li class="line-hit">			}</li>
        <li class="line-hit">		it &#39;returns a function&#39;, -&gt;</li>
        <li class="line-hit">			assert.is.function shapeshift.table { foo: &quot;bar&quot; }</li>
        <li class="line-hit">		it &#39;detects missing keys&#39;, -&gt;</li>
        <li class="line-hit">			assert.falsy person { name: &quot;Henry&quot; }</li>
        <li class="line-hit">		it &#39;recurses validations&#39;, -&gt;</li>
        <li class="line-miss">			assert.falsy person { name: &quot;Henry&quot;, age: &quot;twenty&quot; }</li>
        <li class="line-hit">		it &#39;passes correct validations&#39;, -&gt;</li>
        <li class="line-hit">			assert.truthy person { name: &quot;Henry&quot;, age: 20 }</li>
        <li class="line-hit">		pending &#39;ignores keys starting with __&#39;, -&gt;</li>
        <li class="line-empty">		-- Should this also apply to test subjects?</li>
        <li class="line-miss">		it &#39;respects the __extra option&#39;, -&gt;</li>
        <li class="line-hit">			assert.same { foo: &quot;bar&quot; }, select 2, shapeshift.table(__extra: &quot;keep&quot;)(foo: &quot;bar&quot;)</li>
        <li class="line-hit">			assert.same {  }, select 2, shapeshift.table(__extra: &quot;drop&quot;)(foo: &quot;bar&quot;)</li>
        <li class="line-empty">
</li>
        <li class="line-hit">	describe &#39;default&#39;, -&gt;</li>
        <li class="line-hit">		it &#39;Returns the default only when subject is nil&#39;, -&gt;</li>
        <li class="line-miss">			test = shapeshift.default(&quot;default&quot;)</li>
        <li class="line-hit">			assert.equal &quot;default&quot;, select 2, test(nil)</li>
        <li class="line-hit">			assert.equal &quot;foo&quot;, select 2, test(&quot;foo&quot;)</li>
        <li class="line-hit">			assert.equal false, select 2, test(false)</li>
        <li class="line-hit">	pending &#39;any&#39;, -&gt;</li>
        <li class="line-hit">	pending &#39;all&#39;, -&gt;</li>
        <li class="line-miss">	pending &#39;default&#39;, -&gt;</li>
    </ul>

  </section>

        </section>
      </main>

      <footer class="quiet">
        Code coverage generated by <a href="https://keplerproject.github.io/luacov/" target="_blank">LuaCov</a> at 2022-10-09 10:40:03
      </footer>
    </div>
  </body>
</html>
