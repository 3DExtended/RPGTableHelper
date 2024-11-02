using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.DataLayer.OpenAI.Contracts.Queries
{
    public class AiGenerateImageQuery : IQuery<string, AiGenerateImageQuery>
    {
        public string ImagePrompt { get; set; } = default!;
    }
}
