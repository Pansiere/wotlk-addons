# WotLK Addons

Meus addons para jogar em servidores privados **3.3.5a (Wrath of the Lich King)** — setup pessoal focado em healer (raid + party). Cada pasta neste repositório é um addon pronto para uso.

## Instalação

A pasta que contém o arquivo `.toc` precisa ficar **direto** dentro de `Interface/AddOns/`:

```
Interface/AddOns/NomeDoAddon/
```

Nunca deixe o addon dentro de uma pasta extra tipo `NomeDoAddon-main` ou `NomeDoAddon-master` — o `.toc` tem que estar um nível abaixo de `AddOns`, senão o addon não aparece na lista do jogo.

## Índice

- [🛡️ Boss Mods & Avisos de Raid](#️-boss-mods--avisos-de-raid)
- [💉 Cura (Healer)](#-cura-healer)
- [📋 Organização de Raid](#-organização-de-raid)
- [🎯 Threat](#-threat)
- [📊 Medidores de Dano & Cura](#-medidores-de-dano--cura)
- [🩸 Nameplates](#-nameplates)
- [🎒 Inventário](#-inventário)
- [⚔️ Equipamento](#️-equipamento)
- [🖥️ UI & Qualidade de Vida](#️-ui--qualidade-de-vida)
- [🇧🇷 Específico do Servidor](#-específico-do-servidor)

## 🛡️ Boss Mods & Avisos de Raid

| Addon | O que faz |
|---|---|
| [DBM-Core](./DBM-Core) | Núcleo do Deadly Boss Mods — motor de timers e avisos de mecânicas de boss. |
| [DBM-GUI](./DBM-GUI) | Painel de opções do DBM. |
| [DBM-Party-WotLK](./DBM-Party-WotLK) | Encontros de masmorras (5-man) do WotLK. |
| [DBM-Naxx](./DBM-Naxx) | Encontros de Naxxramas. |
| [DBM-Ulduar](./DBM-Ulduar) | Encontros de Ulduar. |
| [DBM-Onyxia](./DBM-Onyxia) | Encontro da Onyxia. |
| [DBM-VoA](./DBM-VoA) | Encontros do Vault of Archavon. |
| [DBM-Coliseum](./DBM-Coliseum) | Encontros do Trial of the Crusader / Crusaders' Coliseum. |
| [DBM-Icecrown](./DBM-Icecrown) | Encontros da Icecrown Citadel. |
| [DBM-EyeOfEternity](./DBM-EyeOfEternity) | Encontro de Malygos (Eye of Eternity). |
| [DBM-ChamberOfAspects](./DBM-ChamberOfAspects) | Encontro de Halion (Ruby Sanctum). |
| [DBM-WorldEvents](./DBM-WorldEvents) | Avisos de eventos de mundo/feriados. |
| [DBM-PvP](./DBM-PvP) | Avisos para arenas e campos de batalha. |
| [GTFO](./GTFO) | Alerta sonoro imediato quando você está parado em cima de dano no chão. |
| [CDUsed](./CDUsed) | Avisa a raid quando alguém usa um cooldown importante. |
| [RaidCooldowns](./RaidCooldowns) | Rastreia, transmite e exibe os cooldowns de toda a raid. |
| [Flump](./Flump) | Anuncia cooldowns, portais, banquetes e afins no chat. |

## 💉 Cura (Healer)

| Addon | O que faz |
|---|---|
| [HealBot](./HealBot) | Painel de barras clicáveis para cura, decurse, buff, ressurreição, range check e aggro — o addon principal de heal. |
| [PallyPower](./PallyPower) | Gerenciador de buffs de Paladino para grupo/raid. |

## 📋 Organização de Raid

| Addon | O que faz |
|---|---|
| [MRT](./MRT) | Method Raid Tools — notas de raid, marcações no mundo, cooldowns e ferramentas de raid leader. |
| [RaidBuffStatus](./RaidBuffStatus) | Reporta buffs, consumíveis, mana e AFK de todo mundo na raid. |
| [RaidComp](./RaidComp) | Visão geral de quais buffs/debuffs a composição da raid cobre. |
| [RaidSlackCheck](./RaidSlackCheck) | Confere poção, flask e comida de cada um antes do pull (`/rsc`). |

## 🎯 Threat

| Addon | O que faz |
|---|---|
| [Omen](./Omen) | Medidor de ameaça (threat) leve, com suporte a múltiplos alvos. |

## 📊 Medidores de Dano & Cura

| Addon | O que faz |
|---|---|
| [Recount](./Recount) | Gráficos de dano e cura causados/recebidos. |
| [RecountGuessedAbsorbs](./RecountGuessedAbsorbs) | Módulo do Recount que estima absorbs. |
| [RecountHealAndGuessedAbsorbs](./RecountHealAndGuessedAbsorbs) | Módulo do Recount que junta cura e absorb estimado numa única aba. |
| [Skada](./Skada) | Medidor de dano modular — base para os módulos abaixo. |
| [SkadaAbsorbs](./SkadaAbsorbs) | Módulo de absorbs do Skada. |
| [SkadaCC](./SkadaCC) | Módulo de crowd control (quem quebrou CC) do Skada. |
| [SkadaDamage](./SkadaDamage) | Módulo de dano causado do Skada. |
| [SkadaDamageTaken](./SkadaDamageTaken) | Módulo de dano recebido do Skada. |
| [SkadaDeaths](./SkadaDeaths) | Módulo de mortes do Skada. |
| [SkadaDebuffs](./SkadaDebuffs) | Módulo de uptime de debuffs do Skada. |
| [SkadaDispels](./SkadaDispels) | Módulo de dispels e interrupts do Skada. |
| [SkadaEnemies](./SkadaEnemies) | Módulo de dano causado/recebido por inimigos do Skada. |
| [SkadaFailbot](./SkadaFailbot) | Módulo "failbot" (erros mecânicos) do Skada. |
| [SkadaHealing](./SkadaHealing) | Módulo de cura e overheal do Skada. |
| [SkadaPower](./SkadaPower) | Módulo de recurso ganho (mana/energia/etc) do Skada. |
| [SkadaThreat](./SkadaThreat) | Módulo de ameaça do Skada. |

## 🩸 Nameplates

| Addon | O que faz |
|---|---|
| [TidyPlates](./TidyPlates) | Base das nameplates customizadas (backport bkader p/ 3.3.5a, v6.5.0). |
| [TidyPlates_Graphite](./TidyPlates_Graphite) | Tema visual minimalista para o TidyPlates. |
| [TidyPlates_Grey](./TidyPlates_Grey) | Tema visual cinza (bundled) do TidyPlates. |
| [TidyPlates_Neon](./TidyPlates_Neon) | Tema visual neon do TidyPlates. |
| [TidyPlates_Quatre](./TidyPlates_Quatre) | Tema visual alternativo do TidyPlates. |
| [TidyPlates_ThreatPlates](./TidyPlates_ThreatPlates) | Tema que muda a cor da nameplate conforme sua posição no threat. |
| [PlateBuffs](./PlateBuffs) | Mostra buffs/debuffs em cima das nameplates. |

## 🎒 Inventário

| Addon | O que faz |
|---|---|
| [Bagnon](./Bagnon) | Junta todas as bolsas e o banco numa janela só. |
| [Bagnon_Config](./Bagnon_Config) | Tela de configuração do Bagnon. |
| [Bagnon_Forever](./Bagnon_Forever) | Guarda o inventário salvo mesmo com o personagem offline. |
| [Bagnon_GuildBank](./Bagnon_GuildBank) | Janela única para o banco da guilda. |
| [Bagnon_Tooltips](./Bagnon_Tooltips) | Mostra quem tem determinado item ao passar o mouse. |

## ⚔️ Equipamento

| Addon | O que faz |
|---|---|
| [GearScore](./GearScore) | Calcula uma pontuação rápida da qualidade do equipamento de um jogador. |
| [WoWEquip](./WoWEquip) | Simula trocas de equipamento e compara status antes de vestir (tipo CT_Profiles). |
| [BonusScanner](./BonusScanner) | Soma os bônus cumulativos de todo o equipamento. |
| [DrDamage](./DrDamage) | Theorycraft in-game: calcula dano/cura real com base em gear, talentos e buffs. |

## 🖥️ UI & Qualidade de Vida

| Addon | O que faz |
|---|---|
| [ACP](./ACP) | Addon Control Panel — gerenciador de addons dentro do jogo, com suporte a addons multi-parte. |
| [OmniCC](./OmniCC) | Mostra a contagem regressiva em número sobre os ícones de cooldown. |
| [OmniCC_Config](./OmniCC_Config) | Tela de configuração do OmniCC. |
| [UnitFramesImproved](./UnitFramesImproved) | Melhora visualmente as unit frames padrão da Blizzard. |
| [SnowfallKeyPress](./SnowfallKeyPress) | Faz keybinds ativarem ao apertar a tecla, em vez de ao soltar. |
| [SexyCooldown](./SexyCooldown) | Barra de cooldown com escala logarítmica. |
| [Cheese](./Cheese) | Alertas visuais na tela para cooldowns/eventos importantes. |

## 🇧🇷 Específico do Servidor

| Addon | O que faz |
|---|---|
| [WoW Brasil Vip teleport](./WoW%20Brasil%20Vip%20teleport) | Teleporte VIP do servidor: shift + clique num local nomeado no mapa. |

---

Sincronizado com a instalação real em `Interface/AddOns` — sempre que um addon novo é instalado ou atualizado no jogo, o repositório é atualizado junto.
