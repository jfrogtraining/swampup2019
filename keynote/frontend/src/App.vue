<template>
  <div id="app">
    <div>
      <b-navbar toggleable="lg" type="dark" variant="info">
        <b-navbar-brand href="#/">SwampUp 2019</b-navbar-brand>
        <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>
        <b-collapse id="nav-collapse" is-nav>
          <b-navbar-nav>
            <b-nav-item href="#"><router-link to="/">Hello Frogs</router-link> </b-nav-item>
            <b-nav-item href="#"><router-link to="/bootstrap">Get Frogs</router-link> </b-nav-item>
            <b-nav-item href="#"><router-link to="/user">Add Frog</router-link> </b-nav-item>
            <b-nav-item href="#"><router-link to="/service">Frog Facts</router-link> </b-nav-item>
            <b-nav-item href="#"><router-link to="/app">Get App</router-link> </b-nav-item>
          </b-navbar-nav>
        </b-collapse>
      </b-navbar>
    </div>
    <router-view class="main" :hellomsg="msg"></router-view>
  </div>
</template>
<script>

    export default {
        name: 'app',
        data () {
            return {
                msg: 'Welcome to your SwampUp 2019 App'
            }
        }
    }
</script>

<style lang="scss">


  .main {
    width: 100%;
    height: 90vh;
    background: url("../src/assets/san-frame-1.jpg") 100% 50%;
    background-size: cover;
  }

  .router-link-active {
    font-weight: bold;
  }

  .navbar-brand {
    display: inline-block;
    padding-top: 0.3125rem;
    padding-bottom: 0.3125rem;
    margin-right: 1rem;
    font-size: 1.25rem;
    line-height: inherit;
    white-space: nowrap;
  }

  a {
    display: inline-block;
    padding-top: 0.3125rem;
    padding-bottom: 0.3125rem;
    margin-right: 1rem;
    font-size: 1.25rem;
    line-height: inherit;
    white-space: nowrap;
    color: white !important;
  }


  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
  }

  #nav a {
    font-weight: bold;
    color: #2c3e50;
    font-size: 20px;
  }

  #nav a.router-link-exact-active {
    color: #42b983;
    font-size: 25px;
  }

</style>
