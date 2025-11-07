import { Context, z } from 'koishi'

export const name = 'choose'

export interface Config {
  delimiters: string[]
}

export const Config: z<Config> = z.object({
  delimiters: z.array(z.string()).default([' ', '/', ',', ';', '，', '、', '；', '还是', '或(?:者|是)?']).description('分隔符正则表达式列表，请注意 split 方法会把捕获组里的内容追加到分割出的数组里，因此使用非捕获组'),
})

export const usage = `本插件没有注册中间件，推荐和 dialogue 插件同时使用，这里提供示范：
\`\`\`
# -x -E ^选择(.+) $(choose $1)
\`\`\`
`

export function apply(ctx: Context, config: Config) {
  const logger = ctx.logger('choose')
  ctx.i18n.define('zh-CN', require('../locales/zh-CN'))
  const delimiters = new RegExp(`(?:${config.delimiters.join('|')})`, 'u')
  logger.debug('delimiters: ', delimiters)
  ctx.command('choose <input:text>')
    .action(({ session }, input) => {
      if (!delimiters.test(input)) return session.text('.no-delimiter') // no spam by default
      const choices = input.split(delimiters).map(choice => choice?.trim()).filter(Boolean)
      logger.debug('choices: ', choices)
      const num = new Set(choices).size
      if (num < 2) return session.text('.same-choices')
      const chosen = choices[Math.floor(Math.random() * choices.length)]
      return session.text('.chosen', [chosen])
    })
}
