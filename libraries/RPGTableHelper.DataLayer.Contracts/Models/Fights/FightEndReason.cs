namespace RPGTableHelper.DataLayer.Contracts.Models.Fights
{
    /// <summary>Why a fight is over.</summary>
    public enum FightEndReason
    {
        /// <summary>The DM ended the fight.</summary>
        EndedByDm = 0,

        /// <summary>The DM started a new fight in the same campagne while this one was open.</summary>
        ReplacedByNewFight = 1,

        /// <summary>Nothing happened in the fight for <c>FightService.InactivityTimeout</c>.</summary>
        Expired = 2,
    }
}
