/**
 * 每次build的时候往百度手动提交一次链接
 */
const yaml = require('js-yaml')
const fs = require('fs')
const http = require('http')
const querystring = require("querystring")
const glob = require('glob')

const content = yaml.safeLoad(fs.readFileSync(__dirname + '/_config.yml', 'utf8'))

const req = http.request({
  host: 'data.zz.baidu.com',
  method: 'POST',
  path: `/urls?site=${content.url}&token=c9rzJBDCKqdJOGKr`
}, (res) => {
  let content = ''
  res.setEncoding('utf8')
  res.on('data', (chunk) => {
    content += chunk
  });
  res.on('end', () => {
    console.log('推送返回结果:', querystring.parse(content))
  });
})

req.on('error', (e) => {
  console.error(`请求遇到问题: ${e.message}`)
})

/**
 * 找出所有文章地址，推送出去
 */
glob('./public/[0-9]*/**/index.html', (err, files) => {
  if (err) {
    console.error(err)
    return
  }
  files.forEach(path => {
    console.log(`${content.url}` + path.match(/(?:public)(.*)/)[1])
    req.write(`${content.url}` + path.match(/(?:public)(.*)/)[1] + '\n')
  })
  req.end()
})