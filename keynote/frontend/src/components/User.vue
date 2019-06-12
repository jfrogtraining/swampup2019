<template>
  <div class="user">
    <div style="height:8em"></div>

    <h1>Create New Frog</h1>
    <div style="height:1em"></div>

    <input type="text" v-model="user.firstName" placeholder="first name">
    <input type="text" v-model="user.lastName" placeholder="last name">
    <br><br>
    <b-button variant="success" @click="createUser()">Create Frog</b-button>

    <div style="height:2em"></div>

    <div v-if="showResponse"><h3>User created with Id: {{ response }}</h3></div>

    <button v-if="showResponse" @click="retrieveUser()">Retrieve user {{user.id}} data from database</button>

    <h4 v-if="showRetrievedUser">Retrieved User {{retrievedUser.firstName}} {{retrievedUser.lastName}}</h4>

  </div>
</template>

<script>
    // import axios from 'axios'
    import {AXIOS} from './http-common'

    export default {
        name: 'user',

        data () {
            return {
                response: [],
                errors: [],
                user: {
                    lastName: '',
                    firstName: '',
                    id: 0
                },
                showResponse: false,
                retrievedUser: {},
                showRetrievedUser: false
            }
        },
        methods: {
            // Fetches posts when the component is created.
            createUser ()  {
                const params = new URLSearchParams()

                if (this.user.firstName === "" || this.user.lastName === "") {
                    return;
                }

                params.append('firstName', this.user.firstName);
                params.append('lastName', this.user.lastName);

                AXIOS.post(`/user`, params)
                    .then(response => {
                        // JSON responses are automatically parsed.
                        this.response = response.data;
                        this.user.id = response.data;
                        this.showResponse = true;

                        this.user.firstName = "";
                        this.user.lastName = "";

                    })
                    .catch(e => {
                        this.errors.push(e)
                    })
            },
            retrieveUser () {
                AXIOS.get(`/user/` + this.user.id)
                    .then(response => {
                        // JSON responses are automatically parsed.
                        this.retrievedUser = response.data
                        console.log(response.data)
                        this.showRetrievedUser = true
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
  h1, h2, h3 ,h4 {
    font-weight: normal;
    color: white;
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
