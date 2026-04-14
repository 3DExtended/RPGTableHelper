using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;
using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Models.RpgEntities
{
    public class Campagne : NodeModelBase<Campagne.CampagneIdentifier, Guid>
    {
        /// <summary>
        /// This is the json serialized configuration of the rpg
        /// </summary>
        public string? RpgConfiguration { get; set; }

        /// <summary>
        /// Cold (rarely changing) slice of <see cref="RpgConfiguration"/>.
        /// </summary>
        public string? RpgConfigurationCold { get; set; }

        /// <summary>
        /// Hot (frequently changing) slice of <see cref="RpgConfiguration"/>.
        /// </summary>
        public string? RpgConfigurationHot { get; set; }

        /// <summary>
        /// Schema version for the cold/hot split format.
        /// </summary>
        public int? RpgConfigurationSchemaVersion { get; set; }

        /// <summary>
        /// Monotonic revision for <see cref="RpgConfigurationCold"/> (SignalR JSON Patch v3).
        /// </summary>
        public int RpgConfigurationColdRevision { get; set; }

        /// <summary>
        /// Monotonic revision for <see cref="RpgConfigurationHot"/> (SignalR JSON Patch v3).
        /// </summary>
        public int RpgConfigurationHotRevision { get; set; }

        /// <summary>
        /// Monotonic revision for merged <see cref="RpgConfiguration"/> (upstream v3 for full config blob).
        /// </summary>
        public int RpgConfigurationMergedRevision { get; set; }

        public string CampagneName { get; set; } = default!;

        public string JoinCode { get; set; } = default!;

        /// <summary>
        /// The dm of this campagne.
        /// </summary>
        public User.UserIdentifier DmUserId { get; set; } = default!;

        public record CampagneIdentifier : Identifier<Guid, CampagneIdentifier> { }
    }
}
