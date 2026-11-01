namespace RPGTableHelper.DataLayer.Contracts.Models.Fights
{
    /// <summary>Who a fight participant is.</summary>
    public enum FightParticipantKind
    {
        /// <summary>A player character, asked to roll by its owner.</summary>
        Character = 0,

        /// <summary>A companion (or alternate form) of a player character, asked to roll by the character's owner.</summary>
        Companion = 1,

        /// <summary>An opponent the DM added with a roll; never asked.</summary>
        Enemy = 2,
    }
}
