<template>
  <div class="service">
    <div style="height:5em"></div>
    <v-wait for="jfrog-search">
      <template slot="waiting">
        <div class="center-screen">
          <img src="../assets/loader.svg" />
        </div>
      </template>
      <div style="height:1em"></div>
      <b-btn variant="success" @click="callRestService(); showResponse=true" id="btnCallHello">CALL Frog Service</b-btn>
      <div style="height:2em"></div>
      <h1> {{ response }}</h1>
    </v-wait>
  </div>
</template>

<script>
    // import axios from 'axios'
    import {AXIOS} from './http-common'

    export default {
        name: 'service',

        data () {
            return {
                response: "",
                errors: []
            }
        },
        methods: {
            // Fetches posts when the component is created.
            callRestService () {
                this.$wait.start('jfrog-search');
                AXIOS.get(`/service`)
                    .then(response => {
                        // JSON responses are automatically parsed.
                        this.response = response.data
                        console.log(response.data)
                        this.$wait.end('jfrog-search');
                    })
                    .catch(e => {
                        this.errors.push(e)
                    })
            }
        }
    }

</script>


<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

  .card {
    margin: 50px;
  }

  .center-screen {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    text-align: center;
    min-height: 60vh;
  }

  h1, h2 {
    font-weight: normal;
  }

  ul {
    list-style-type: none;
    padding: 0;
  }

  li {
    display: inline-block;
    margin: 0 10px;
  }

  a {
    color: #42b983;
  }
</style>
