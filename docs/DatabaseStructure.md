# Firebase Firestore Database Structure

## Game

- Rooms = will contain user's public information and for match making
    - /userId
        - ownerId
        - status (online, offline, gaming, searching, etc.)
        - player: FetchedPlayer
        - challengers: [FetchedPlayer]
    
- Games = will contain a list of games currently happening between 2 players
    - /lobbyId
        - ownerInitiallyHasSpeedBoost
        - player
        - enemyPlayer
        - /Rounds
            - /roundNumber
                - createdAt, p1SelectedMoves, p2SelectedMoves

- Histories = will contain a list of game history results
    - /userId/History/lobbyIds
        - enemyId, username, winnerId (or didWin boolean), winnerHpLeft, roundNumber, experienceGained, createDate,
