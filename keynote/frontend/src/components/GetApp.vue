<template>
  <div class="hello">
    <div style="height:7em"></div>
    <img alt="frog" src="./../assets/qr-code.png" class="responsive"/>    <div style="height:2em"></div>
    <h1>Get Application</h1>
  </div>
</template>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  @media screen and (max-width:1024px){
    img.responsive {width: 200px;}
  }

  @media screen and (min-width:1025px){
    img.responsive{width: 300px;}
  }

  img.responsive{height: auto;}

h1, h2 {
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
