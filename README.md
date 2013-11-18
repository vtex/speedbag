# Tiny Speedbag

## Grunt
Less, Livereload, Concat, Uglify, Cssmin, Local server e Proxy

## Projeto
jQuery, Angularjs, Twitter Bootstrap 3, Font-Awesome e Underscore.js

[Leandro Oriente](http://leandrooriente.com/) - [Projeto Original](https://github.com/vtex/speedbag)

### Dependências

  Grunt, Node

### Como usar
  
  npm i

### Local (arquivos abertos)
  
  grunt

### Build (arquivos minificados e concatenados)
  
  grunt dist

### Testar build local
  
  grunt distLocal

## Problemas comuns

- Caso deseje rodar o proxy e/ou o server numa porta inferior a 1024 (80 por exemplo) é necessário rodar o grunt como root (sudo).

- Se quiser usar um domínio customizado no remote, é necessário adicionar ao arquivo de host apontando para localhost.